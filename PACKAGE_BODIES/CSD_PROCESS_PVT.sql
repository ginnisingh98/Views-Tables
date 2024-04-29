--------------------------------------------------------
--  DDL for Package Body CSD_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_PROCESS_PVT" AS
    /* $Header: csdvintb.pls 120.39.12010000.10 2010/06/03 20:36:50 nnadig ship $ */

    -- ---------------------------------------------------------
    -- Define global variables
    -- ---------------------------------------------------------

    G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_PROCESS_PVT';
    G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvintb.pls';
    g_debug NUMBER := Csd_Gen_Utility_Pvt.g_debug_level;

    /* R12 Srl reservation changes, begin */
    C_RESERVABLE  CONSTANT NUMBER := 1;
    C_SERIAL_CONTROL_AT_RECEIPT  CONSTANT NUMBER := 5;
    C_SERIAL_CONTROL_PREDEFINED CONSTANT NUMBER := 2;
    /* R12 Srl reservation changes, end */


    -- Global variable for storing the debug level
    G_debug_level NUMBER := Fnd_Log.G_CURRENT_RUNTIME_LEVEL;

    /*-------------------------------------------------------------------------------------*/
    /* Function  name: DEBUG                                                               */
    /* Description   : Logs the debug message                                              */
    /* Called from   : Called from Update API                                              */
    /*                                                                                     */
    /* STANDARD PARAMETERS                                                                 */
    /*   In Parameters :                                                                   */
    /*      p_message        Required    Debug message that needs to be logged             */
    /*      p_mod_name       Required    Module name                                       */
    /*      p_severity_level Required    Severity level                                    */
    /*   Output Parameters:                                                                */
    /* NON-STANDARD PARAMETERS                                                             */
    /*   In Parameters                                                                     */
    /*   Out parameters                                                                    */
    /* Change Hist :                                                                       */
    /*   09/20/03  vlakaman  Initial Creation.                                             */
    /*-------------------------------------------------------------------------------------*/

    PROCEDURE DEBUG(p_message        IN VARCHAR2,
                    p_mod_name       IN VARCHAR2,
                    p_severity_level IN NUMBER) IS

        -- Variables used in FND Log
        l_stat_level  NUMBER := Fnd_Log.LEVEL_STATEMENT;
        l_proc_level  NUMBER := Fnd_Log.LEVEL_PROCEDURE;
        l_event_level NUMBER := Fnd_Log.LEVEL_EVENT;
        l_excep_level NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_unexp_level NUMBER := Fnd_Log.LEVEL_UNEXPECTED;

    BEGIN

        IF p_severity_level = 1
        THEN
            IF (l_stat_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_stat_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 2
        THEN
            IF (l_proc_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_proc_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 3
        THEN
            IF (l_event_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_event_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 4
        THEN
            IF (l_excep_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_excep_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 5
        THEN
            IF (l_error_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_error_level, p_mod_name, p_message);
            END IF;
        ELSIF p_severity_level = 6
        THEN
            IF (l_unexp_level >= G_debug_level)
            THEN
                Fnd_Log.STRING(l_unexp_level, p_mod_name, p_message);
            END IF;
        END IF;

			Csd_Gen_Utility_Pvt.add(p_message);

    END DEBUG;
    /*--------------------------------------------------*/
    /* procedure name: process_service_request          */
    /* description   : procedure used to create         */
    /*                 service requests                 */
    /*--------------------------------------------------*/

    PROCEDURE process_service_request(p_api_version         IN NUMBER,
                                      p_commit              IN VARCHAR2 := Fnd_Api.g_false,
                                      p_init_msg_list       IN VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level    IN NUMBER := Fnd_Api.g_valid_level_full,
                                      p_action              IN VARCHAR2,
                                      p_incident_id         IN NUMBER := NULL,
                                      p_service_request_rec IN Csd_Process_Pvt.SERVICE_REQUEST_REC,
                                      x_incident_id         OUT NOCOPY NUMBER,
                                      x_incident_number     OUT NOCOPY VARCHAR2,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2) IS

      l_notes_tbl     Cs_Servicerequest_Pub.NOTES_TABLE;

    BEGIN

       process_service_request(p_api_version         => p_api_version,
                               p_commit              => p_commit,
                               p_init_msg_list       => p_init_msg_list,
                               p_validation_level    => p_validation_level,
                               p_action              => p_action,
                               p_incident_id         => p_incident_id,
                               p_service_request_rec => p_service_request_rec,
                               p_notes_tbl           => l_notes_tbl,
                               x_incident_id         => x_incident_id,
                               x_incident_number     => x_incident_number,
                               x_return_status       => x_return_status,
                               x_msg_count           => x_msg_count,
                               x_msg_data            => x_msg_data );

    END process_Service_request;

    /*--------------------------------------------------*/
    /* procedure name: process_service_request          */
    /* description   : procedure used to create         */
    /*                 service requests                 */
    /*--------------------------------------------------*/

    PROCEDURE process_service_request(p_api_version         IN  NUMBER,
                                      p_commit              IN  VARCHAR2 := Fnd_Api.g_false,
                                      p_init_msg_list       IN  VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level    IN  NUMBER := Fnd_Api.g_valid_level_full,
                                      p_action              IN  VARCHAR2,
                                      p_incident_id         IN  NUMBER := NULL,
                                      p_service_request_rec IN  Csd_Process_Pvt.SERVICE_REQUEST_REC,
                                      p_notes_tbl           IN  Cs_Servicerequest_Pub.NOTES_TABLE,
                                      x_incident_id         OUT NOCOPY NUMBER,
                                      x_incident_number     OUT NOCOPY VARCHAR2,
                                      x_return_status       OUT NOCOPY VARCHAR2,
                                      x_msg_count           OUT NOCOPY NUMBER,
                                      x_msg_data            OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'PROCESS_SERVICE_REQUEST';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count           NUMBER;
        l_msg_data            VARCHAR2(2000);
        l_msg_index           NUMBER;
        r_service_request_rec Cs_Servicerequest_Pub.service_request_rec_type;
        t_contacts_table      Cs_Servicerequest_Pub.contacts_table;
        ln_interaction_id     NUMBER;
        ln_workflow_id        NUMBER;
        ln_individual_owner   NUMBER;
        ln_group_owner        NUMBER;
        ln_individual_type    VARCHAR2(100);

        CURSOR c_party_site_id(p_party_site_use_id IN NUMBER) IS
            SELECT party_site_id
              FROM hz_party_site_uses
             WHERE party_site_use_id = p_party_site_use_id;

        CURSOR c_party_id(p_party_site_id IN NUMBER) IS
            SELECT party_id
              FROM hz_party_sites
             WHERE party_site_id = p_party_site_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT process_service_request;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        IF (g_debug > 5)
        THEN
            Csd_Gen_Utility_Pvt.ADD('dump_sr_rec');
            Csd_Gen_Utility_Pvt.dump_sr_rec(p_sr_rec => p_service_request_rec);
        END IF;

        -- Assign the SR rec values
        Cs_Servicerequest_Pub.initialize_rec(r_service_request_rec);
        r_service_request_rec.request_date  := p_service_request_rec.request_date;
        r_service_request_rec.type_id       := p_service_request_rec.type_id;
        r_service_request_rec.type_name     := p_service_request_rec.type_name;
        r_service_request_rec.status_id     := p_service_request_rec.status_id;
        r_service_request_rec.status_name   := p_service_request_rec.status_name;
        r_service_request_rec.severity_id   := p_service_request_rec.severity_id;
        r_service_request_rec.severity_name := p_service_request_rec.severity_name;
        r_service_request_rec.urgency_id    := p_service_request_rec.urgency_id;
        r_service_request_rec.urgency_name  := p_service_request_rec.urgency_name;
        r_service_request_rec.closed_date   := p_service_request_rec.closed_date;
        r_service_request_rec.owner_id      := p_service_request_rec.owner_id;

        -- swai: 02-07-03
        -- do not pass owner_group_id since group_type is not available
        -- passing owner_group_id without group_type may cause SR validation
        -- errors
        -- r_service_request_rec.owner_group_id        := p_service_request_rec.owner_group_id;
        r_service_request_rec.publish_flag             := p_service_request_rec.publish_flag;
        r_service_request_rec.summary                  := p_service_request_rec.summary;
        r_service_request_rec.caller_type              := p_service_request_rec.caller_type;
        r_service_request_rec.customer_id              := p_service_request_rec.customer_id;
        r_service_request_rec.customer_number          := p_service_request_rec.customer_number;
        r_service_request_rec.employee_id              := p_service_request_rec.employee_id;
        r_service_request_rec.employee_number          := p_service_request_rec.employee_number;
        r_service_request_rec.customer_product_id      := p_service_request_rec.customer_product_id;
        r_service_request_rec.cp_ref_number            := p_service_request_rec.cp_ref_number;
        r_service_request_rec.inventory_item_id        := p_service_request_rec.inventory_item_id;
        r_service_request_rec.inventory_org_id         := p_service_request_rec.inventory_org_id;
        r_service_request_rec.current_serial_number    := p_service_request_rec.current_serial_number;
        r_service_request_rec.original_order_number    := p_service_request_rec.original_order_number;
        r_service_request_rec.purchase_order_num       := p_service_request_rec.purchase_order_num;
        r_service_request_rec.problem_code             := p_service_request_rec.problem_code;
        r_service_request_rec.exp_resolution_date      := p_service_request_rec.exp_resolution_date;
        r_service_request_rec.bill_to_site_use_id      := p_service_request_rec.bill_to_site_use_id;
        r_service_request_rec.ship_to_site_use_id      := p_service_request_rec.ship_to_site_use_id;
        r_service_request_rec.contract_id              := p_service_request_rec.contract_id;
        r_service_request_rec.account_id               := p_service_request_rec.account_id;
        r_service_request_rec.resource_type            := p_service_request_rec.resource_type;
        r_service_request_rec.cust_po_number           := p_service_request_rec.cust_po_number;
        r_service_request_rec.cp_revision_id           := p_service_request_rec.cp_revision_id;
        r_service_request_rec.inv_item_revision        := p_service_request_rec.inv_item_revision;
        r_service_request_rec.sr_creation_channel      := p_service_request_rec.sr_creation_channel;
        r_service_request_rec.creation_program_code    := 'CSD_REPAIR_ORDER_FORM';
        r_service_request_rec.last_update_program_code := 'CSD_REPAIR_ORDER_FORM';
        r_service_request_rec.group_type               := 'RS_GROUP';

       /*Fixed for bug#5589395
	    Pass the DFF value to Service API.
	  */
        r_service_request_rec.external_context        := p_service_request_rec.external_context;
        r_service_request_rec.external_attribute_1    := p_service_request_rec.external_attribute_1;
        r_service_request_rec.external_attribute_2    := p_service_request_rec.external_attribute_2;
        r_service_request_rec.external_attribute_3    := p_service_request_rec.external_attribute_3;
        r_service_request_rec.external_attribute_4    := p_service_request_rec.external_attribute_4;
        r_service_request_rec.external_attribute_5    := p_service_request_rec.external_attribute_5;
        r_service_request_rec.external_attribute_6    := p_service_request_rec.external_attribute_6;
        r_service_request_rec.external_attribute_7    := p_service_request_rec.external_attribute_7;
        r_service_request_rec.external_attribute_8    := p_service_request_rec.external_attribute_8;
        r_service_request_rec.external_attribute_9    := p_service_request_rec.external_attribute_9;
        r_service_request_rec.external_attribute_10   := p_service_request_rec.external_attribute_10;
        r_service_request_rec.external_attribute_11   := p_service_request_rec.external_attribute_11;
        r_service_request_rec.external_attribute_12   := p_service_request_rec.external_attribute_12;
        r_service_request_rec.external_attribute_13   := p_service_request_rec.external_attribute_13;
        r_service_request_rec.external_attribute_14   := p_service_request_rec.external_attribute_14;
        r_service_request_rec.external_attribute_15   := p_service_request_rec.external_attribute_15;


        -- Contacts
        -- swai - forward port bug 2767101
        -- Do not set the contact record if no contact was specified.
        -- setting these fields to null may cause SR API to fail
        IF (p_service_request_rec.party_id IS NOT NULL)
        THEN
            t_contacts_table(1).sr_contact_point_id := p_service_request_rec.sr_contact_point_id;
            t_contacts_table(1).party_id            := p_service_request_rec.party_id;
            t_contacts_table(1).contact_type        := p_service_request_rec.contact_type;
            t_contacts_table(1).contact_point_id    := p_service_request_rec.contact_point_id;
            t_contacts_table(1).contact_point_type  := p_service_request_rec.contact_point_type;
            t_contacts_table(1).primary_flag        := p_service_request_rec.primary_flag;
        END IF;

        Csd_Gen_Utility_Pvt.ADD('GETTING BILL-TO FIELDS');
        -- Bill-To fields
        IF (NVL(p_service_request_rec.bill_to_site_use_id,
                Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM)
        THEN
            OPEN c_party_site_id(p_service_request_rec.bill_to_site_use_id);
            FETCH c_party_site_id
                INTO r_service_request_rec.bill_to_site_id;
            CLOSE c_party_site_id;
            Csd_Gen_Utility_Pvt.ADD('r_service_request_rec.bill_to_site_id ' ||
                                    r_service_request_rec.bill_to_site_id);
            IF (NVL(r_service_request_rec.bill_to_site_id,
                    Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM)
            THEN
                OPEN c_party_id(r_service_request_rec.bill_to_site_id);
                FETCH c_party_id
                    INTO r_service_request_rec.bill_to_party_id;
                CLOSE c_party_id;
                Csd_Gen_Utility_Pvt.ADD('r_service_request_rec.bill_to_party_id ' ||
                                        r_service_request_rec.bill_to_party_id);
            END IF;
        END IF;

        -- Ship-To fields
        Csd_Gen_Utility_Pvt.ADD('GETTING SHIP-TO FIELDS');
        IF (NVL(p_service_request_rec.ship_to_site_use_id,
                Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM)
        THEN
            OPEN c_party_site_id(p_service_request_rec.ship_to_site_use_id);
            FETCH c_party_site_id
                INTO r_service_request_rec.ship_to_site_id;
            CLOSE c_party_site_id;
            Csd_Gen_Utility_Pvt.ADD('r_service_request_rec.ship_to_site_id ' ||
                                    r_service_request_rec.ship_to_site_id);
            IF (NVL(r_service_request_rec.ship_to_site_id,
                    Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM)
            THEN
                OPEN c_party_id(r_service_request_rec.ship_to_site_id);
                FETCH c_party_id
                    INTO r_service_request_rec.ship_to_party_id;
                CLOSE c_party_id;
                Csd_Gen_Utility_Pvt.ADD('r_service_request_rec.ship_to_party_id ' ||
                                        r_service_request_rec.ship_to_party_id);
            END IF;
        END IF;

        -- Call to Service Request API
        IF (UPPER(p_action) = 'CREATE')
        THEN
            Cs_Servicerequest_Pub.Create_ServiceRequest(p_api_version         => 3.0,
                                                        p_init_msg_list       => Fnd_Api.G_FALSE,
                                                        p_commit              => Fnd_Api.G_FALSE,
                                                        x_return_status       => x_return_status,
                                                        x_msg_count           => x_msg_count,
                                                        x_msg_data            => x_msg_data,
                                                        p_resp_appl_id        => NULL,
                                                        p_resp_id             => NULL,
                                                        p_user_id             => Fnd_Global.user_id,
                                                        p_login_id            => Fnd_Global.conc_login_id,
                                                        p_org_id              => NULL,
                                                        p_request_id          => p_incident_id,
                                                        p_request_number      => p_service_request_rec.incident_number, -- swai: FP 5157216,
                                                        p_service_request_rec => r_service_request_rec,
                                                        p_notes               => p_notes_tbl,
                                                        p_contacts            => t_contacts_table,
                                                        x_request_id          => x_incident_id,
                                                        x_request_number      => x_incident_number,
                                                        x_interaction_id      => ln_interaction_id,
                                                        x_workflow_process_id => ln_workflow_id,
                                                        x_individual_owner    => ln_individual_owner,
                                                        x_group_owner         => ln_group_owner,
                                                        x_individual_type     => ln_individual_type);

        END IF;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO process_service_request;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_service_request;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_service_request;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END process_service_request;

    /*--------------------------------------------------*/
    /* procedure name: process_charge_lines             */
    /* description   : procedure used to create/update  */
    /*                 delete charge lines              */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE process_charge_lines(p_api_version        IN NUMBER,
                                   p_commit             IN VARCHAR2 := Fnd_Api.g_false,
                                   p_init_msg_list      IN VARCHAR2 := Fnd_Api.g_false,
                                   p_validation_level   IN NUMBER := Fnd_Api.g_valid_level_full,
                                   p_action             IN VARCHAR2,
                                   p_Charges_Rec        IN Cs_Charge_Details_Pub.Charges_Rec_Type,
                                   x_estimate_detail_id OUT NOCOPY NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_msg_count          OUT NOCOPY NUMBER,
                                   x_msg_data           OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'PROCESS_CHARGE_LINES';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_msg_index             NUMBER;
        l_estimate_detail_id    NUMBER;
        l_charges_rec           Cs_Charge_Details_Pub.Charges_Rec_Type;
        x_object_version_number NUMBER;
        x_line_number           NUMBER;
        l_invoice_to_org_id      NUMBER;  -- nnadig: bug 9395568
        l_ship_to_org_id         NUMBER;  -- nnadig: bug 9395568


        -- Variables used in FND Log
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_process_pvt.process_charge_lines';

    BEGIN
        Debug('At the Beginning of process_charge_lines', l_mod_name, 1);

        -- Standard Start of API savepoint
        SAVEPOINT process_charge_lines;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts

        Debug('Validate the action', l_mod_name, 1);

        -- Validate the action code
        IF NOT (Csd_Process_Util.VALIDATE_ACTION(p_action, l_api_name))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        l_charges_rec := p_charges_rec;

        -- nnadig: bug 9395568
        -- If this is an existing charge line, get the current
        -- bill-to and ship-to site information so that
        -- we can compare them with what is being passed in.
        if (l_Charges_Rec.estimate_detail_id is not null and
           l_Charges_Rec.estimate_detail_id <> FND_API.G_MISS_NUM) then
         BEGIN
          select invoice_to_org_id, ship_to_org_id
          into l_invoice_to_org_id, l_ship_to_org_id
          from cs_estimate_details
          where estimate_detail_id = l_Charges_Rec.estimate_detail_id;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
               debug('No existing Charges record',l_mod_name,1);
               RAISE FND_API.G_EXC_ERROR;
         END;
         if (l_invoice_to_org_id <> l_Charges_Rec.invoice_to_org_id) then
             l_Charges_Rec.bill_to_account_id := NULL;
         end if;
         if (l_ship_to_org_id <> l_Charges_Rec.ship_to_org_id) then
             l_Charges_Rec.ship_to_account_id := NULL;
         end if;
        end if;
       -- end nnadig: bug 9395568

        /* Fixed for forward port bug#4214359.
           Whenever we pass the invoice_to_org_id corresponding bill_to_party_id should be passed
           otherwise charges API will validate the bill_to_org_id against the party_id at
           Service Request level and it would error out if the bill to address selected at product
           line level is of related party.
        */
        IF (l_Charges_Rec.invoice_to_org_id IS NOT NULL AND
           l_Charges_Rec.invoice_to_org_id <> Fnd_Api.G_MISS_NUM)
        THEN
            BEGIN
                SELECT party_id
                  INTO l_Charges_Rec.bill_to_party_id
                  FROM hz_party_sites
                 WHERE party_site_id = l_Charges_Rec.invoice_to_org_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    debug('No Bill to Party Id', l_mod_name, 1);
                    RAISE Fnd_Api.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                    debug('Too many Bill to Party Id', l_mod_name, 1);
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        /* Fixed for forward port bug#4214359.
           Whenever we pass the ship_to_org_id corresponding ship_to_party_id should be passed
           otherwise charges API will validate the ship_to_org_id against the party_id at
           Service Request level and it would error out if the ship to address selected at product
           line level is of related party.
        */
        IF (l_Charges_Rec.ship_to_org_id IS NOT NULL AND
           l_Charges_Rec.ship_to_org_id <> Fnd_Api.G_MISS_NUM)
        THEN
            BEGIN
                SELECT party_id
                  INTO l_Charges_Rec.ship_to_party_id
                  FROM hz_party_sites
                 WHERE party_site_id = l_Charges_Rec.ship_to_org_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    debug('No Ship to Party Id', l_mod_name, 1);
                    RAISE Fnd_Api.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                    debug('Too many Ship to Party Id', l_mod_name, 1);
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        -- Based on the action, call the respective charges public api to
        -- to create/update/delete the charge lines.
        IF p_action = 'CREATE'
        THEN

            Debug('Creating the charge lines ', l_mod_name, 1);
            Debug('l_charges_rec.transaction_type_id :' ||
                  TO_CHAR(l_charges_rec.transaction_type_id),
                  l_mod_name,
                  1);

            Cs_Charge_Details_Pub.Create_Charge_Details(p_api_version           => p_api_version,
                                                        p_init_msg_list         => p_init_msg_list,
                                                        p_commit                => p_commit,
                                                        p_validation_level      => p_validation_level,
                                                        p_transaction_control   => Fnd_Api.G_TRUE,
                                                        p_Charges_Rec           => l_charges_rec,
                                                        x_object_version_number => x_object_version_number,
                                                        x_estimate_detail_id    => x_estimate_detail_id,
                                                        x_line_number           => x_line_number,
                                                        x_return_status         => x_return_status,
                                                        x_msg_count             => x_msg_count,
                                                        x_msg_data              => x_msg_data);

            Debug('Return Status from Create_Charge_Details' ||
                  x_return_status,
                  l_mod_name,
                  1);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('Create_Charge_Details failed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSIF p_action = 'UPDATE'
        THEN

            Debug('Creating the charge lines ', l_mod_name, 1);
            Debug('Estimate Detail Id = ' ||
                  l_Charges_Rec.estimate_detail_id,
                  l_mod_name,
                  1);
            Debug('l_Charges_Rec.business_process_id=' ||
                  l_Charges_Rec.business_process_id,
                  l_mod_name,
                  1);

            IF ((NVL(l_Charges_Rec.business_process_id, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM) AND
               l_Charges_Rec.estimate_detail_id IS NOT NULL)
            THEN
                BEGIN
                    SELECT business_process_id
                      INTO l_Charges_Rec.business_process_id
                      FROM cs_estimate_details
                     WHERE estimate_detail_id =
                           l_Charges_Rec.estimate_detail_id;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        Debug('No Business business_process_id',
                              l_mod_name,
                              1);
                        RAISE Fnd_Api.G_EXC_ERROR;
                    WHEN TOO_MANY_ROWS THEN
                        Debug('Too many business_process_id',
                              l_mod_name,
                              1);
                        RAISE Fnd_Api.G_EXC_ERROR;
                END;
            END IF;

            Debug('l_Charges_Rec.business_process_id=' ||
                  l_Charges_Rec.business_process_id,
                  l_mod_name,
                  1);

            Cs_Charge_Details_Pub.Update_Charge_Details(p_api_version           => p_api_version,
                                                        p_init_msg_list         => p_init_msg_list,
                                                        p_commit                => p_commit,
                                                        p_validation_level      => p_validation_level,
                                                        p_transaction_control   => Fnd_Api.G_TRUE,
                                                        p_Charges_Rec           => l_Charges_Rec,
                                                        x_object_version_number => x_object_version_number,
                                                        x_return_status         => x_return_status,
                                                        x_msg_count             => x_msg_count,
                                                        x_msg_data              => x_msg_data);

            Debug('Return Status from Update_Charge_Details' ||
                  x_return_status,
                  l_mod_name,
                  1);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('update_charge_details failed', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSIF p_action = 'DELETE'
        THEN

            Debug('l_estimate_detail_id =' || l_estimate_detail_id,
                  l_mod_name,
                  1);
            Debug('Deleting the charge lines ', l_mod_name, 1);

            l_estimate_detail_id := l_charges_rec.estimate_detail_id;

            Cs_Charge_Details_Pub.Delete_Charge_Details(p_api_version         => p_api_version,
                                                        p_init_msg_list       => p_init_msg_list,
                                                        p_commit              => p_commit,
                                                        p_validation_level    => p_validation_level,
                                                        p_transaction_control => Fnd_Api.G_TRUE,
                                                        p_estimate_detail_id  => l_estimate_detail_id,
                                                        x_return_status       => x_return_status,
                                                        x_msg_count           => x_msg_count,
                                                        x_msg_data            => x_msg_data);

            Debug('Return Status from Delete_Charge_Details' ||
                  x_return_status,
                  l_mod_name,
                  1);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('Delete_Charge_Details failed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO process_charge_lines;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_charge_lines;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_charge_lines;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END process_charge_lines;

    /*--------------------------------------------------*/
    /* procedure name: apply_contract                   */
    /* description   : procedure used to apply contract */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE apply_contract(p_api_version      IN NUMBER,
                             p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                             p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                             p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                             p_incident_id      IN NUMBER,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'APPLY_CONTRACT';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count NUMBER;
        l_msg_data  VARCHAR2(2000);
        l_msg_index NUMBER;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT apply_contract;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate the incident id');
            Csd_Gen_Utility_Pvt.ADD('p_incident_id  =' || p_incident_id);
        END IF;

        IF NOT (Csd_Process_Util.VALIDATE_INCIDENT_ID(p_incident_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Applying contract on charge lines');
        END IF;

        -- Commented
        -- signature change to be discussed.
        --       CS_EST_APPLY_CONTRACT_PKG.APPLY_CONTRACT
        --                  (p_incident_id    =>   p_incident_id ) ;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO apply_contract;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO apply_contract;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO apply_contract;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END apply_contract;

    /*--------------------------------------------------*/
    /* procedure name: ship_sales_order                 */
    /* description   : procedure used to ship           */
    /*                 sales Order                      */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE ship_sales_order(p_api_version      IN NUMBER,
                               p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                               p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                               p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                               p_delivery_id      IN OUT NOCOPY NUMBER,
                               x_return_status    OUT NOCOPY VARCHAR2,
                               x_msg_count        OUT NOCOPY NUMBER,
                               x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'SHIP_SALES_ORDER';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
        l_dummy              VARCHAR2(1);
        l_header_rec         Aso_Quote_Pub.Qte_Header_Rec_Type;
        l_line_tbl           Aso_Quote_Pub.Qte_Line_Tbl_Type;
        l_Line_dtl_tbl       Aso_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
        l_hd_shipment_rec    Aso_Quote_Pub.Shipment_rec_Type;
        l_hd_shipment_tbl    Aso_Quote_Pub.Shipment_tbl_Type;
        l_ln_shipment_tbl    Aso_Quote_Pub.Shipment_Tbl_Type;
        l_hd_payment_tbl     Aso_Quote_Pub.Payment_Tbl_Type; -- added by cnemalik
        l_line_price_adj_tbl Aso_Quote_Pub.Price_Adj_Tbl_Type;
        x_order_header_rec   Aso_Order_Int.Order_Header_rec_type;
        x_order_line_tbl     Aso_Order_Int.Order_Line_tbl_type;
        x_order_header_id    NUMBER;
        l_control_rec        Aso_Order_Int.control_rec_type;
        -- Following two variables are defined to fix bug 3437177
        l_Serial_number_control_code NUMBER;
        C_SRL_NUM_Cnt_Code_SO_ISSUE CONSTANT NUMBER := 6;

        -- Parameters for WSH_DELIVERIES_PUB.Delivery_Action.
        --p_delivery_id   NUMBER;
        p_action_code             VARCHAR2(15);
        p_delivery_name           VARCHAR2(30);
        p_asg_trip_id             NUMBER;
        p_asg_trip_name           VARCHAR2(30);
        p_asg_pickup_stop_id      NUMBER;
        p_asg_pickup_loc_id       NUMBER;
        p_asg_pickup_loc_code     VARCHAR2(30);
        p_asg_pickup_arr_date     DATE;
        p_asg_pickup_dep_date     DATE;
        p_asg_dropoff_stop_id     NUMBER;
        p_asg_dropoff_loc_id      NUMBER;
        p_asg_dropoff_loc_code    VARCHAR2(30);
        p_asg_dropoff_arr_date    DATE;
        p_asg_dropoff_dep_date    DATE;
        p_sc_action_flag          VARCHAR2(10);
        p_sc_intransit_flag       VARCHAR2(10);
        p_sc_close_trip_flag      VARCHAR2(10);
        p_sc_create_bol_flag      VARCHAR2(10);
        p_sc_stage_del_flag       VARCHAR2(10);
        p_sc_trip_ship_method     VARCHAR2(30);
        p_sc_actual_dep_date      VARCHAR2(30);
        p_sc_defer_interface_flag VARCHAR2(1);
        p_sc_report_set_id        NUMBER;
        p_sc_report_set_name      VARCHAR2(60);
        p_wv_override_flag        VARCHAR2(10);
        x_trip_id                 VARCHAR2(30);
        x_trip_name               VARCHAR2(30);
        x_msg_details             VARCHAR2(3000);
        x_msg_summary             VARCHAR2(3000);
        l_customer_id             NUMBER := NULL;
        l_order_type_id           NUMBER := NULL;
        l_document_set_id         NUMBER := NULL;
        l_sub_inventory           VARCHAR2(30) := '';

        --Parameters for WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes.
        source_code        VARCHAR2(15);
        changed_attributes Wsh_Delivery_Details_Pub.ChangedAttributeTabType;

        /* Handle exceptions */
        fail_api EXCEPTION;
        -- Added Mtl_Sytem_items_B to get serial_number_control_Code for the item that is being
        -- shipped. This is to fix bug 3437177 saupadhy
        -- Added condition that release status should be 'Y' which 'Staged/Pick Confirmed'

        CURSOR delivery(p_del_id IN NUMBER) IS
            SELECT cr.serial_number,
                   wdd.delivery_detail_id,
                   wdd.requested_quantity,
                   mtl.serial_number_control_code
              FROM csd_repairs              cr,
                   mtl_system_items_b       mtl,
                   cs_estimate_details      ced,
                   wsh_delivery_details     wdd,
			    --Changed to view from table, bug:  4341784
                   wsh_delivery_assignments_v wda
             WHERE cr.repair_line_id = ced.original_source_id
               AND ced.original_source_code = 'DR'
               AND ced.order_line_id = wdd.source_line_id
	       AND  wdd.SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
               AND wdd.delivery_detail_id = wda.delivery_detail_id
               AND wdd.released_status = 'Y'
               AND wda.delivery_id = p_del_id
               AND wdd.inventory_item_id = mtl.inventory_item_id
               AND wdd.ship_from_location_id = mtl.organization_id;

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT ship_sales_order;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts

        -- dbms_application_info.set_client_info('204');
        -- fnd_global.apps_initialize(1000200,52284,512,0);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        -- If action is SHIP, then call shipping api to
        -- ship the sales order
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Shipping the Sales Order');
            Csd_Gen_Utility_Pvt.ADD('p_delivery_id =' || p_delivery_id);
        END IF;

        IF NVL(p_delivery_id, Fnd_Api.G_MISS_NUM) = Fnd_Api.G_MISS_NUM
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_INV_DELIVERY_ID');
            Fnd_Message.SET_TOKEN('DELIVERY_ID', p_delivery_id);
            Fnd_Msg_Pub.ADD;
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Delivery_id is invalid');
            END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
        ELSE

            BEGIN
                SELECT '*'
                  INTO l_dummy
                  FROM wsh_new_deliveries
                 WHERE delivery_id = p_delivery_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_INV_DELIVERY_ID');
                    Fnd_Message.SET_TOKEN('DELIVERY_ID', p_delivery_id);
                    Fnd_Msg_Pub.ADD;
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('Delivery_id is invalid');
                    END IF;
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        FOR i IN delivery(p_delivery_id)
        LOOP

            -- In case of serial controlled at SO issue item, update the serial number on the
            -- delivery line details
            -- This change was made to fix bug 3437177

            -- IF NVL(i.serial_number, FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR THEN
            IF i.Serial_number_control_code = C_SRL_NUM_Cnt_Code_SO_ISSUE AND
               NVL(i.serial_number, Fnd_Api.G_MISS_CHAR) <>
               Fnd_Api.G_MISS_CHAR
            THEN
                BEGIN
                    source_code := 'OE'; -- The only source code that should be used by the API
                    changed_attributes(1).delivery_detail_id := i.delivery_detail_id;
                    changed_attributes(1).serial_number := i.serial_number;
                    changed_attributes(1).shipped_quantity := i.requested_quantity;
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('delivery_detail_id =' ||
                                                changed_attributes(1)
                                                .delivery_detail_id);
                        Csd_Gen_Utility_Pvt.ADD('serial_number      =' ||
                                                changed_attributes(1)
                                                .serial_number);
                        Csd_Gen_Utility_Pvt.ADD('shipped_quantity   =' ||
                                                changed_attributes(1)
                                                .shipped_quantity);
                        Csd_Gen_Utility_Pvt.ADD('Calling Update_Shipping_Attributes');
                    END IF;
                    --Call to WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes.
                    Wsh_Delivery_Details_Pub.Update_Shipping_Attributes(p_api_version_number => 1.0,
                                                                        p_init_msg_list      => p_init_msg_list,
                                                                        p_commit             => p_commit,
                                                                        x_return_status      => x_return_status,
                                                                        x_msg_count          => x_msg_count,
                                                                        x_msg_data           => x_msg_data,
                                                                        p_changed_attributes => changed_attributes,
                                                                        p_source_code        => source_code);
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('x_return_status(Update_Shipping_Attributes )=' ||
                                                x_return_status);
                    END IF;
                    IF (x_return_status <> Wsh_Util_Core.G_RET_STS_SUCCESS)
                    THEN
                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('Update_Shipping_Attributes failed');
                        END IF;
                        RAISE fail_api;
                    END IF;
                EXCEPTION
                    WHEN fail_api THEN
                        Wsh_Util_Core.get_messages('Y',
                                                   x_msg_summary,
                                                   x_msg_details,
                                                   x_msg_count);
                        IF x_msg_count > 1
                        THEN
                            x_msg_data := x_msg_summary || x_msg_details;
                        ELSE
                            x_msg_data := x_msg_summary;
                        END IF;
                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('Error Msg from Update_Shipping_Attributes');
                            Csd_Gen_Utility_Pvt.ADD('x_msg_data = ' ||
                                                    x_msg_data);
                        END IF;
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_UPDATE_SHIPPING_FAILED');
                        Fnd_Message.SET_TOKEN('ERR_MSG', x_msg_data);
                        Fnd_Msg_Pub.ADD;
                        RAISE Fnd_Api.G_EXC_ERROR;
                END;

            END IF; --end of update_shipping_attributes

        END LOOP;

        BEGIN

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('p_delivery_id=' || p_delivery_id);
            END IF;

            -- Values for Ship Confirming the delivery.
            p_action_code    := 'CONFIRM'; -- The action code for ship confirm
            p_delivery_id    := p_delivery_id; -- The delivery that needs to be confirmed
            p_delivery_name  := TO_CHAR(p_delivery_id); -- The delivery name,
            p_sc_action_flag := 'S'; -- Ship entered quantity.
            -- p_Sc_Intransit_flag needs to be set to 'Y' this as per bug 3676488 (Shipping)
            -- This fix for bug# 3665544
            p_sc_intransit_flag := 'Y'; -- In transit flag is set to 'Y' closes the
            -- pickup stop and sets the delivery in transit.
            p_sc_close_trip_flag := 'Y'; -- Close the trip after ship confirm
            --        p_sc_trip_ship_method := ''; -- The ship method code
            p_sc_defer_interface_flag := 'N'; -- defer interface
            --        p_sc_report_set_id    := 6; -- check if it is seeded

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Calling Delivery_Action ');
            END IF;

            -- Call to WSH_DELIVERIES_PUB.Delivery_Action.
            Wsh_Deliveries_Pub.Delivery_Action(p_api_version_number      => 1.0,
                                               p_init_msg_list           => p_init_msg_list,
                                               x_return_status           => x_return_status,
                                               x_msg_count               => x_msg_count,
                                               x_msg_data                => x_msg_data,
                                               p_action_code             => p_action_code,
                                               p_delivery_id             => p_delivery_id,
                                               p_delivery_name           => p_delivery_name,
                                               p_asg_trip_id             => p_asg_trip_id,
                                               p_asg_trip_name           => p_asg_trip_name,
                                               p_asg_pickup_stop_id      => p_asg_pickup_stop_id,
                                               p_asg_pickup_loc_id       => p_asg_pickup_loc_id,
                                               p_asg_pickup_loc_code     => p_asg_pickup_loc_code,
                                               p_asg_pickup_arr_date     => p_asg_pickup_arr_date,
                                               p_asg_pickup_dep_date     => p_asg_pickup_dep_date,
                                               p_asg_dropoff_stop_id     => p_asg_dropoff_stop_id,
                                               p_asg_dropoff_loc_id      => p_asg_dropoff_loc_id,
                                               p_asg_dropoff_loc_code    => p_asg_dropoff_loc_code,
                                               p_asg_dropoff_arr_date    => p_asg_dropoff_arr_date,
                                               p_asg_dropoff_dep_date    => p_asg_dropoff_dep_date,
                                               p_sc_action_flag          => p_sc_action_flag,
                                               p_sc_intransit_flag       => p_sc_intransit_flag,
                                               p_sc_close_trip_flag      => p_sc_close_trip_flag,
                                               p_sc_create_bol_flag      => p_sc_create_bol_flag,
                                               p_sc_stage_del_flag       => p_sc_stage_del_flag,
                                               p_sc_trip_ship_method     => p_sc_trip_ship_method,
                                               p_sc_actual_dep_date      => p_sc_actual_dep_date,
                                               p_sc_report_set_id        => p_sc_report_set_id,
                                               p_sc_report_set_name      => p_sc_report_set_name,
                                               p_sc_defer_interface_flag => p_sc_defer_interface_flag,
                                               p_wv_override_flag        => p_wv_override_flag,
                                               x_trip_id                 => x_trip_id,
                                               x_trip_name               => x_trip_name);

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('x_return_status(Delivery_Action )=' ||
                                        x_return_status);
            END IF;

            IF (x_return_status <> Wsh_Util_Core.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Delivery_Action failed');
                END IF;
                RAISE fail_api;
            END IF;
        EXCEPTION
            WHEN fail_api THEN
                Wsh_Util_Core.get_messages('Y',
                                           x_msg_summary,
                                           x_msg_details,
                                           x_msg_count);
                IF x_msg_count > 1
                THEN
                    x_msg_data := x_msg_summary || x_msg_details;
                ELSE
                    x_msg_data := x_msg_summary;
                END IF;
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Error Msg from Delivery_Action');
                    Csd_Gen_Utility_Pvt.ADD('x_msg_data = ' || x_msg_data);
                END IF;

                -- Ignore if it is a warning
                IF (x_return_status <> Wsh_Util_Core.G_RET_STS_WARNING)
                THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_SHIP_CONFIRM_FAILED');
                    Fnd_Message.SET_TOKEN('ERR_MSG', x_msg_data);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;

        END; -- end of delivery action

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO ship_sales_order;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO ship_sales_order;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO ship_sales_order;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END ship_sales_order;


/********************************************************
	procedure dbg_print_stack(p_msg_count number, p_mod_name varchar2) is
	l_msg varchar2(2000);
     l_stat_level  NUMBER := Fnd_Log.LEVEL_STATEMENT;

	begin
	  IF p_MSG_COUNT > 1 THEN
	    FOR i IN 1..p_MSG_COUNT LOOP
	     l_msg := apps.FND_MSG_PUB.Get(i,apps.FND_API.G_FALSE) ;
          Fnd_Log.STRING(l_stat_level, p_mod_name, l_msg);
	    END LOOP ;
	  ELSE
	     l_msg := apps.FND_MSG_PUB.Get(1,apps.FND_API.G_FALSE) ;
          Fnd_Log.STRING(l_stat_level, p_mod_name, l_msg);
	  END IF ;

	end dbg_print_stack;
************************************************************/

    /*--------------------------------------------------*/
    /* procedure name: process_sales_order              */
    /* description   : procedure used to create/book    */
    /*                 release and ship sales Order     */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE process_sales_order(p_api_version      IN NUMBER,
                                  p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                  p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                  p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                  p_action           IN VARCHAR2,
                                  /*Fixed for bug#4433942 added product
                                  txn record as in parameter
                                  */
                                  p_product_txn_rec  IN  PRODUCT_TXN_REC default null,
                                  p_order_rec        IN OUT NOCOPY OM_INTERFACE_REC,
                                  x_return_status    OUT NOCOPY VARCHAR2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'PROCESS_SALES_ORDER';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count       NUMBER;
        l_msg_data        VARCHAR2(2000);
        l_msg_index       NUMBER;
        p_rule_id         NUMBER := p_order_rec.picking_rule_id;
        l_batch_name      VARCHAR2(30);
        l_batch_id        NUMBER;
        l_temp            NUMBER;
        l_user_id         NUMBER;
        l_login_id        NUMBER;
        l_dummy1          VARCHAR2(2000);
        l_dummy2          VARCHAR2(10);
        l_ret_code        BOOLEAN;
        p_batch_prefix    VARCHAR2(10) := 'DR';
        x_order_header_id NUMBER;

        l_header_rec         Aso_Quote_Pub.Qte_Header_Rec_Type;
        l_line_tbl           Aso_Quote_Pub.Qte_Line_Tbl_Type;
        l_Line_dtl_tbl       Aso_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
        l_hd_shipment_rec    Aso_Quote_Pub.Shipment_rec_Type;
        l_hd_shipment_tbl    Aso_Quote_Pub.Shipment_tbl_Type;
        l_ln_shipment_tbl    Aso_Quote_Pub.Shipment_Tbl_Type;
        l_hd_payment_tbl     Aso_Quote_Pub.Payment_Tbl_Type;
        l_line_price_adj_tbl Aso_Quote_Pub.Price_Adj_Tbl_Type;
        x_order_header_rec   Aso_Order_Int.Order_Header_rec_type;
        x_order_line_tbl     Aso_Order_Int.Order_Line_tbl_type;
        l_control_rec        Aso_Order_Int.control_rec_type;

        -- Parameters for WSH_DELIVERIES_PUB.Delivery_Action.
        p_delivery_id             NUMBER;
        p_action_code             VARCHAR2(15);
        p_delivery_name           VARCHAR2(30);
        p_asg_trip_id             NUMBER;
        p_asg_trip_name           VARCHAR2(30);
        p_asg_pickup_stop_id      NUMBER;
        p_asg_pickup_loc_id       NUMBER;
        p_asg_pickup_loc_code     VARCHAR2(30);
        p_asg_pickup_arr_date     DATE;
        p_asg_pickup_dep_date     DATE;
        p_asg_dropoff_stop_id     NUMBER;
        p_asg_dropoff_loc_id      NUMBER;
        p_asg_dropoff_loc_code    VARCHAR2(30);
        p_asg_dropoff_arr_date    DATE;
        p_asg_dropoff_dep_date    DATE;
        p_sc_action_flag          VARCHAR2(10);
        p_sc_intransit_flag       VARCHAR2(10);
        p_sc_close_trip_flag      VARCHAR2(10);
        p_sc_create_bol_flag      VARCHAR2(10);
        p_sc_stage_del_flag       VARCHAR2(10);
        p_sc_trip_ship_method     VARCHAR2(30);
        p_sc_actual_dep_date      VARCHAR2(30);
        p_sc_defer_interface_flag VARCHAR2(1);
        p_sc_report_set_id        NUMBER;
        p_sc_report_set_name      VARCHAR2(60);
        p_wv_override_flag        VARCHAR2(10);
        x_trip_id                 VARCHAR2(30);
        x_trip_name               VARCHAR2(30);
        x_msg_details             VARCHAR2(3000);
        x_msg_summary             VARCHAR2(3000);
        l_customer_id             NUMBER := NULL;
        l_order_type_id           NUMBER := NULL;
        l_document_set_id         NUMBER := NULL;
        l_sub_inventory           VARCHAR2(30) := '';
        l_Organization_Id         NUMBER := NULL;
        l_org_id                  NUMBER;
        l_locator_id              NUMBER;
	lx_Request_ID             Number ; -- R12 : SU

	    --bug#6071005
		l_delivery_detail_id	  NUMBER := NULL;

        /*Fixed bug#4433942 following variable has been defined */
        C_SRL_NUM_Cnt_Code_SO_ISSUE Constant Number := 6 ;
        l_revision                   VARCHAR2(10);
        l_shipped_serial_number      VARCHAR2(30);
        l_lot_number                 VARCHAR2(80); -- fix for bug#4625226
        l_SN_at_SO_new_SN_number     BOOLEAN; /*This flag is true when user provide new SN for serialized item at SO */

        --Parameters for WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes.
        source_code        VARCHAR2(15);
        changed_attributes Wsh_Delivery_Details_Pub.ChangedAttributeTabType;


--bug#7675562
  l_ship_param_info		WSH_SHIPPING_PARAMS_GRP.Shipping_Params_Rec;


        /*Handle exceptions*/
        fail_api EXCEPTION;

        -- bug#8269688, FP of bug#7659800, subhat
        l_shipped_flag varchar2(1);
        -- end bug#8269688, FP of bug#7659800, subhat

        CURSOR pick_rule(x_rule_id IN NUMBER) IS
            SELECT PICKING_RULE_ID
              FROM WSH_PICKING_RULES
             WHERE PICKING_RULE_ID = x_rule_id
               AND SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE) AND
                   NVL(END_DATE_ACTIVE, SYSDATE + 1);

        CURSOR batch(x_batch_name IN VARCHAR2) IS
            SELECT batch_id
              FROM WSH_PICKING_BATCHES
             WHERE NAME = x_batch_name;

        CURSOR move_order(x_batch_name IN VARCHAR2) IS
            SELECT header_id
              FROM MTL_TXN_REQUEST_HEADERS
             WHERE request_number = x_batch_name;

        CURSOR customer(p_ord_header_id IN NUMBER) IS
            SELECT a.sold_to_org_id,
                   a.order_type_id,
                   a.source_document_type_id
              FROM oe_order_headers_all a
             WHERE a.header_id = p_ord_header_id;

        CURSOR delivery(p_ord_header_id IN NUMBER, p_ord_line_id IN NUMBER) IS
            SELECT b.delivery_id,
                   a.delivery_detail_id,
                   c.serial_number_control_code,
             /* Fix for bug# 4433942 */
                   c.lot_control_code,
                   c.revision_qty_control_code,
                   c.reservable_type,
                   a.organization_id,
                   a.inventory_item_id,
                   c.segment1 item_name,
                   p.organization_code
              FROM wsh_delivery_details     a,
			    --Changed to view from table, bug:  4341784
                   wsh_delivery_assignments_v b,
                   mtl_system_items         c,
                   mtl_parameters  p
             WHERE a.delivery_detail_id = b.delivery_detail_id
               AND a.inventory_item_id = c.inventory_item_id
               AND a.organization_id = c.organization_id
               AND a.released_status = 'Y'
	       AND  a.SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
               AND a.source_header_id = p_ord_header_id
               AND a.source_line_id = p_ord_line_id
               AND a.organization_id = p.organization_id;

       CURSOR c_get_org_id (p_header_id IN NUMBER) IS
          SELECT org_id
          FROM oe_order_headers_all
          WHERE header_id = p_header_id;

        -- Variables used in FND Log
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_process_pvt.process_sales_order';

	   /* pick release rule api changes/srl reservations changes *
	   */
	  l_batch_rec   WSH_PICKING_BATCHES_PUB.Batch_Info_Rec ;
	  l_ret_status varchar2(1);
	  l_reservation_id number;

	  cursor c_srl_reservation(p_srl_num varchar2, p_item_id number) is
	  select reservation_id from mtl_Serial_numbers
	  where serial_number = p_srl_num
	  and inventory_item_Id = p_item_id;

      --bug#6071005
	  cursor get_delivery_detail_id(p_order_header_id IN NUMBER, p_order_line_id IN NUMBER) IS
	  select delivery_detail_id
	  from wsh_Delivery_Details
	  where source_header_id = p_order_header_id and source_line_id = p_order_line_id;


    BEGIN
        -- Debug message
        Debug('At the Beginning of process_sales_order', l_mod_name, 1);

        -- Standard Start of API savepoint
        SAVEPOINT process_sales_order;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts

        -- dbms_application_info.set_client_info('204');
        -- fnd_global.apps_initialize(1000200,52284,512,0);

        Debug('Validate the action code', l_mod_name, 1);

        -- Validate the action code
        IF NOT (Csd_Process_Util.VALIDATE_ACTION(p_action, l_api_name))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF p_action = 'CREATE'
        THEN

            -- If action is CREATE, then call charges private api to
            -- create sales order
            Debug('Creating the Sales Order', l_mod_name, 1);
            Debug('p_order_rec.incident_id =' || p_order_rec.incident_id,
                  l_mod_name,
                  1);
            Debug('p_order_rec.party_id    =' || p_order_rec.party_id,
                  l_mod_name,
                  1);
            Debug('p_order_rec.account_id  =' || p_order_rec.account_id,
                  l_mod_name,
                  1);

            Cs_Charge_Create_Order_Pub.Submit_Order(p_api_version      => 1.0,
                                                    p_init_msg_list    => p_init_msg_list,
                                                    p_commit           => p_commit,
                                                    p_validation_level => p_validation_level,
                                                    p_incident_id      => p_order_rec.incident_id,
                                                    p_party_id         => p_order_rec.party_id,
                                                    p_account_id       => p_order_rec.account_id,
                                                    p_book_order_flag  => 'N',
                                                    x_return_status    => x_return_status,
                                                    x_msg_count        => x_msg_count,
                                                    x_msg_data         => x_msg_data);

            Debug('Return Status from Submit_Order' || x_return_status,
                  l_mod_name,
                  1);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('Submit_Order API failed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

        ELSIF p_action = 'BOOK'
        THEN

            -- If action is BOOK, then call charges private api to
            -- book the sales order
            Debug('Booking the Sales Order', l_mod_name, 1);
            Debug('p_order_rec.order_header_id =' ||
                  p_order_rec.order_header_id,
                  l_mod_name,
                  1);
            Debug('p_order_rec.org_id          =' || p_order_rec.org_id,
                  l_mod_name,
                  1);

            l_header_rec.org_id           := p_order_rec.org_id;
            l_header_rec.order_id         := p_order_rec.order_header_id;
            l_control_rec.book_flag       := Fnd_Api.G_TRUE;
            l_control_rec.calculate_price := Fnd_Api.G_FALSE;

     	    open  c_get_org_id(p_order_rec.order_header_id);
	    fetch c_get_org_id into l_org_id;
	    close c_get_org_id;


            -- Set the Policy context as required for MOAC Uptake, Bug#4421242
            mo_global.set_policy_context('S',l_org_id);


            Aso_Order_Int.Update_order(P_Api_Version_Number => 1.0,
                                       P_Init_Msg_List      => Fnd_Api.G_TRUE,
                                       P_Commit             => Fnd_Api.G_FALSE,
                                       P_Qte_Rec            => l_header_rec,
                                       P_Qte_Line_Tbl       => l_line_tbl,
                                       P_Qte_Line_Dtl_Tbl   => l_line_dtl_tbl,
                                       P_Line_Shipment_Tbl  => l_ln_shipment_tbl,
                                       P_Header_Payment_Tbl => l_hd_payment_tbl,
                                       P_Line_Price_Adj_Tbl => l_line_price_adj_tbl,
                                       P_Control_Rec        => l_control_rec,
                                       X_Order_Header_Rec   => x_order_header_rec,
                                       X_Order_Line_Tbl     => x_order_line_tbl,
                                       X_Return_Status      => x_return_status,
                                       X_Msg_Count          => x_msg_count,
                                       X_Msg_Data           => x_msg_data);

           -- Change the Policy context back to multiple
           mo_global.set_policy_context('M',null);

           Debug('Return Status from Update_order' || x_return_status,
                  l_mod_name,
                  1);

           IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
           THEN
             Debug('ASO_ORDER_INT.UPDATE_ORDER failed', l_mod_name, 1);
             RAISE Fnd_Api.G_EXC_ERROR;
           END IF;

        ELSIF p_action = 'PICK-RELEASE'
        THEN

            Debug('Releasing Sales Order', l_mod_name, 1);
            Debug('p_order_rec.order_header_id =' ||
                  p_order_rec.order_header_id,
                  l_mod_name,
                  1);

            -- If action is BOOK, then call charges private api to
            -- book the sales order

            IF NVL(p_order_rec.order_header_id, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_ORDER_HEADER_ID');
                Fnd_Message.SET_TOKEN('ORDER_HEADER_ID',
                                      p_order_rec.order_header_id);
                Fnd_Msg_Pub.ADD;
                Debug('Invalid Order header Id is passed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF NVL(p_order_rec.PICKING_RULE_ID, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_PICKING_RULE_ID');
                Fnd_Message.SET_TOKEN('PICKING_RULE_ID',
                                      p_order_rec.PICKING_RULE_ID);
                Fnd_Msg_Pub.ADD;
                Debug('Invalid Picking rule Id is passed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- Fetch user and login information
            l_user_id  := Fnd_Global.USER_ID;
            l_login_id := Fnd_Global.CONC_LOGIN_ID;

            -- Validate Picking Rule
            OPEN pick_rule(p_order_rec.PICKING_RULE_ID);
            FETCH pick_rule
                INTO l_temp;
            IF pick_rule%NOTFOUND
            THEN
                Debug('The picking rule ' || p_order_rec.PICKING_RULE_ID ||
                      'does not exist or has expired',
                      l_mod_name,
                      1);
                CLOSE pick_rule;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            IF pick_rule%ISOPEN
            THEN
                CLOSE pick_rule;
            END IF;

            -- Get the customer/order details
            OPEN customer(p_order_rec.order_header_id);
            FETCH customer
                INTO l_customer_id, l_order_type_id, l_document_set_id;

            IF customer%NOTFOUND
            THEN
                Debug('invalid order header id ', l_mod_name, 1);
                CLOSE customer;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF customer%ISOPEN
            THEN
                CLOSE customer;
            END IF;

            IF NVL(p_order_rec.org_id, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM
            THEN
                l_Organization_Id := NULL;
            ELSIF p_Order_Rec.Org_Id IS NULL
            THEN
                l_Organization_Id := NULL;
            ELSE
                l_Organization_Id := p_order_rec.org_id;
            END IF;

            IF NVL(p_order_rec.pick_from_subinventory, Fnd_Api.G_MISS_CHAR) =
               Fnd_Api.G_MISS_CHAR
            THEN
                l_sub_inventory := '';
            ELSIF p_Order_Rec.Pick_From_Subinventory IS NULL
            THEN
                l_Sub_Inventory := '';
            ELSE
                l_sub_inventory := p_order_rec.pick_from_subinventory;
            END IF;

            -- Fix for Enh Req#3948563
            IF ((p_order_rec.locator_id is null) or (p_order_rec.locator_id = FND_API.G_MISS_NUM)) THEN
              l_locator_id := null;
            ELSE
              l_locator_id := p_order_rec.locator_id;
            END IF;

			--bug#6071005
			--'A' means "All ship lines in an order",
			--'S' menas "Selected ship line only"
			--if the profile value set to "Selected ship line only", then pass the delivery_detail_id
			--else it will pass null value to delivery_detail_id.
			If (fnd_profile.value('CSD_PROCESS_AUTO_PICK_RELEASE') = 'S') then
     			open  get_delivery_detail_id(p_order_rec.order_header_id, p_order_rec.order_line_id);
				fetch get_delivery_detail_id into l_delivery_detail_id;
				close get_delivery_detail_id;
			End if;

		  --R12 : SU Putting Insert statement in Begin and End Block

      Begin
       SELECT 	NVL(DOCUMENT_SET_ID, l_document_set_id),
           'I', -- Include backorders also 11.5.10 saupadhy: BACKORDERS_ONLY_FLAG,
            NVL(EXISTING_RSVS_ONLY_FLAG, 'N'),
            SHIPMENT_PRIORITY_CODE,
            p_order_rec.order_header_id,
			l_delivery_detail_id,					--bug#6071005
            l_order_type_id,
            NULL, --SHIP_FROM_LOCATION_ID,
            l_customer_id,
            NULL, --SHIP_TO_LOCATION_ID,
            SHIP_METHOD_CODE,
            NVL(l_Sub_Inventory, PICK_FROM_SUBINVENTORY),
            NVL(l_locator_id,PICK_FROM_LOCATOR_ID), -- Fix for Enh Req#3948563 NULL, --PICK_FROM_LOCATOR_ID,
            DEFAULT_STAGE_SUBINVENTORY,
            DEFAULT_STAGE_LOCATOR_ID,
            AUTODETAIL_PR_FLAG,
            AUTO_PICK_CONFIRM_FLAG,
            SHIP_SET_NUMBER,
            NULL, --INVENTORY_ITEM_ID,
            NULL,
            NULL,
            NULL,
            NULL,
            PICK_GROUPING_RULE_ID,
            PICK_SEQUENCE_RULE_ID,
            NVL(l_Organization_Id, ORGANIZATION_ID),
            PROJECT_ID,
            TASK_ID,
            INCLUDE_PLANNED_LINES,
            AUTOCREATE_DELIVERY_FLAG
	INTO
            l_batch_rec.Document_set_id,
            l_batch_Rec.Backorders_only_flag,
            l_batch_rec.Existing_Rsvs_Only_Flag,
		  l_batch_rec.Shipment_Priority_Code,
            l_batch_rec.order_header_id,
			l_batch_rec.delivery_detail_id,			--bug#6071005
            l_batch_rec.order_type_id,
            l_batch_rec.ship_from_location_id,
            l_batch_rec.customer_id,
            l_batch_rec.ship_to_location_id,
            l_batch_rec.ship_method_code,
            l_batch_rec.pick_from_subinventory,
            l_batch_rec.pick_from_locator_id,
            l_batch_rec.default_stage_subinventory,
            l_batch_rec.default_stage_locator_id,
             l_batch_rec.autodetail_pr_flag,
             l_batch_rec.auto_pick_confirm_flag,
            l_batch_rec.ship_set_number,
            l_batch_rec.inventory_item_id,
            l_batch_rec.From_requested_date,
            l_batch_rec.to_Requested_date,
            l_batch_rec.from_scheduled_ship_date,
            l_batch_Rec.to_scheduled_ship_date,
            l_batch_Rec.pick_grouping_rule_id,
            l_batch_rec.pick_sequence_rule_id,
            l_batch_rec.organization_id,
            l_batch_rec.project_id,
            l_batch_rec.task_id,
            l_batch_rec.Include_Planned_Lines,
            l_batch_rec.Autocreate_Delivery_Flag
	FROM WSH_PICKING_RULES
	WHERE PICKING_RULE_ID = p_order_rec.PICKING_RULE_ID;


          Exception
               WHEN OTHERS THEN
                  Fnd_Message.SET_NAME('CSD', 'CSD_PICK_RELEASE_FAIL');
                  Fnd_Message.SET_TOKEN('BATCH_NAME', l_batch_name);
                  Fnd_Msg_Pub.ADD;
                  Debug(' Picking rules insert failed ',l_mod_name, 1);
                  RAISE Fnd_Api.G_EXC_ERROR;
	  End ;

      /* override the auto pick confirm flag if the serial_number is reserved. */
      Debug(' serial_number['||p_product_txn_rec.source_serial_number||']',l_mod_name, 1);
      Debug(' item['||to_char(p_product_txn_rec.inventory_item_id)||']',l_mod_name, 1);
	 if(nvl(p_product_txn_rec.source_serial_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR) then
     	 Open c_srl_reservation(p_product_txn_rec.source_serial_number, p_product_txn_rec.inventory_item_Id);
     	 FETCH c_Srl_reservation into l_reservation_Id;
     	 if(c_Srl_reservation%notfound)then
     	     l_reservation_id := null;
     	 end if;
     	 Close c_srl_reservation;
           Debug(' rsv_id['||to_char(nvl(l_reservation_id,0))||']',l_mod_name, 1);
     	 if(l_reservation_Id is not null) then
               l_batch_rec.auto_pick_confirm_flag := 'Y';
     	 end if;
	 end if;
      Debug(' pick_confirm_flag['||l_batch_Rec.auto_pick_confirm_flag||']',l_mod_name, 1);

        WSH_PICKING_BATCHES_GRP.Create_Batch(
	    p_api_version_number     => 1.0,
	    p_init_msg_list	     => FND_API.G_FALSE,
	    p_commit		     => FND_API.G_FALSE,
	    x_return_status	     => l_ret_status,
	    x_msg_count		     => l_msg_count,
	    x_msg_data		     => l_msg_data,
	    p_rule_id		     => p_order_rec.PICKING_RULE_ID,
	    p_rule_name		     => null,
	    p_batch_rec		     => l_batch_rec,
	    p_batch_prefix	     => p_batch_prefix,
	    x_batch_id		     => l_batch_id);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
           THEN
             Debug('WSH_PICKINGBATCHES_GRP.Create_batch failed', l_mod_name, 1);
             RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
	   Debug('Batch created batch_id=['||l_batch_id||']',l_mod_name,1);

	   wsh_picking_batches_pub.Release_Batch (
		   -- Standard parameters
		   p_api_version     => 1.0,
		   p_init_msg_list   => Fnd_API.G_False,
		   p_commit          => Fnd_API.G_False,
		   x_return_status   => x_Return_Status,
		   x_msg_count       => x_Msg_Count,
		   x_msg_data        => x_Msg_Data,
		   -- program specific paramters.
		   p_batch_id       => l_Batch_ID,
             p_batch_name     => l_Batch_Name,
		   p_log_level      => NULL,
             p_release_mode   => 'ONLINE',
             x_request_id     => lx_Request_ID ) ;

	  Debug('After release Batch, msg_data['||x_msg_data||']' ||
	         'x_return_status=['||x_return_status||']', l_mod_name,1);
	  --dbg_print_stack(x_msg_count, l_mod_name);

          -- begin bug#9369021 , nnadig
          IF x_return_status = wsh_util_core.g_ret_sts_warning THEN
            Debug('release batch returning warning - interpreting that as success!', l_mod_name,1);
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
          END IF;
          -- end bug#9369021


	  IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)
	  THEN
	     Fnd_Message.SET_NAME('CSD', 'CSD_PICK_RELEASE_FAIL');
	     Fnd_Message.SET_TOKEN('BATCH_NAME', l_batch_name);
	     Fnd_Msg_Pub.ADD;
	     Debug('WSH_PICK_LIST.RELEASE_BATCH failed for batch : ' ||
		  l_batch_name,
		  l_mod_name,1) ;
	     RAISE Fnd_Api.G_EXC_ERROR;
	   END IF;
	   Debug('Batch processed, req_id=['||lx_request_id||']',l_mod_name,1);

        ELSIF p_action = 'SHIP'
        THEN

            -- If action is SHIP, then call shipping api to ship the sales order
            Debug('Shipping the Sales Order', l_mod_name, 1);
            Debug('p_order_rec.order_header_id =' ||
                  p_order_rec.order_header_id,
                  l_mod_name,
                  1);

            IF NVL(p_order_rec.order_header_id, Fnd_Api.G_MISS_NUM) =
               Fnd_Api.G_MISS_NUM
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_ORDER_HEADER_ID');
                Fnd_Message.SET_TOKEN('ORDER_HEADER_ID',
                                      p_order_rec.order_header_id);
                Fnd_Msg_Pub.ADD;
                Debug('Order_header_id is invalid', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            FOR i IN delivery(p_order_rec.order_header_id,
                              p_order_rec.order_line_id)
            LOOP

                /* Fix for bug#4433942 -- Code Commented
                -- In case of serialized item, update the serial number on the
                -- delivery line details
                -- Update the serial number on the delivery lines only if the item
                -- is serialized at SO issue
                IF i.serial_number_control_code = 6 AND
                   NVL(p_order_rec.serial_number, Fnd_Api.G_MISS_CHAR) <>
                   Fnd_Api.G_MISS_CHAR
                THEN

                    BEGIN
                        source_code := 'OE'; -- The only source code that should be used by the API
                        changed_attributes(1).delivery_detail_id := i.delivery_detail_id;
                        changed_attributes(1).serial_number := p_order_rec.serial_number;
                        changed_attributes(1).shipped_quantity := p_order_rec.shipped_quantity;

                        Debug('delivery_detail_id =' ||
                              changed_attributes(1).delivery_detail_id,
                              l_mod_name,
                              1);
                        Debug('serial_number      =' ||
                              changed_attributes(1).serial_number,
                              l_mod_name,
                              1);
                        Debug('shipped_quantity   =' ||
                              changed_attributes(1).shipped_quantity,
                              l_mod_name,
                              1);
                        Debug('Calling Update_Shipping_Attributes',
                              l_mod_name,
                              1);

                        --Call to WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes.
                        Wsh_Delivery_Details_Pub.Update_Shipping_Attributes(p_api_version_number => 1.0,
                                                                            p_init_msg_list      => p_init_msg_list,
                                                                            p_commit             => p_commit,
                                                                            x_return_status      => x_return_status,
                                                                            x_msg_count          => x_msg_count,
                                                                            x_msg_data           => x_msg_data,
                                                                            p_changed_attributes => changed_attributes,
                                                                            p_source_code        => source_code);

                        Debug('x_return_status(Update_Shipping_Attributes )=' ||
                              x_return_status,
                              l_mod_name,
                              1);

                        IF (x_return_status <>
                           Wsh_Util_Core.G_RET_STS_SUCCESS)
                        THEN
                            Debug('Update_Shipping_Attributes failed',
                                  l_mod_name,
                                  1);
                            RAISE fail_api;
                        END IF; */

                /*Fixed for bug#4433942
                Psuedo code for new solution is as follows:
                If Item is Reservable then
                  Check if item is Serial Controlled @ SO Issue
                  ( This is existing solution and it will continue to stay
                  If item is serial controlled at Sales Order issue then
                    Call API WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes
                    and update with serial_number and quantity.
                    End If;
                  Else If Item is Non-Reservable
                    If Item is serial Controlled then
                      Get Lot_Number, Revision, Sub Inventory Information from
                      Mtl_Serial_numbers for a given serial_number, item_id,organization_id

                      Call API WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes and
                      Update Serial_Number, Quantity ( will be 1 for serial controlled
                      items), lot_number, Revision and subinventory
                    Else if item is non serial controlled then
                      Call API WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes
                      Values for Quantity, Lot_Number, Revision and Sub Inventory
                      should be pulled from UI.
                      Update Quantity, Lot_Number, Revision and Sub-Inventory
                  End If ;
                End If;
                */
                /* Fixed for bug#3438685
                In case of serial controlled at SO issue item, update the serial number on the
                delivery line details
                */

                BEGIN

                  IF( i.RESERVABLE_TYPE = 1) Then /*Item is reservable */
                    IF i.serial_number_control_code = C_SRL_NUM_Cnt_Code_SO_Issue Then

                      source_code := 'OE'; -- The only source code that should be used by the API
                      changed_attributes(1).delivery_detail_id := i.delivery_detail_id;
                      changed_attributes(1).serial_number      := p_order_rec.serial_number;
                      changed_attributes(1).shipped_quantity   := p_order_rec.shipped_quantity;

                      IF (g_debug > 0 ) THEN
                        csd_gen_utility_pvt.ADD('delivery_detail_id ='||changed_attributes(1).delivery_detail_id);
                        csd_gen_utility_pvt.ADD('serial_number      ='||changed_attributes(1).serial_number );
                        csd_gen_utility_pvt.ADD('shipped_quantity   ='||changed_attributes(1).shipped_quantity );
                        csd_gen_utility_pvt.ADD('Calling Update_Shipping_Attributes');
                      END IF;


                      --Call to WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes.
                      WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes(
                        p_api_version_number => 1.0,
                        p_init_msg_list      => p_init_msg_list,
                        p_commit             => p_commit,
                        x_return_status      => x_return_status,
                        x_msg_count          => x_msg_count,
                        x_msg_data           => x_msg_data,
                        p_changed_attributes => changed_attributes,
                        p_source_code        => source_code);

                      IF (g_debug > 0 ) THEN
                        csd_gen_utility_pvt.ADD('x_return_status(Update_Shipping_Attributes )='||x_return_status);
                      END IF;

                      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                        IF (g_debug > 0 ) THEN
                          csd_gen_utility_pvt.ADD('Update_Shipping_Attributes failed');
                        END IF;
                        RAISE fail_api;
                      END IF;
                    END IF; /* end if of Serial control at sales order and reservable item */

                  Elsif (i.RESERVABLE_TYPE = 2 ) then   /* else of reservable type */

                    /*Bug#4433942 Validations for non reservable item
                    1) If item is serialized make sure that Serial Number resides in the warehouse specified on
                       Ship line,if not raise error. for serial control at receipt/pre-defined.
                    2) If item is non-serialized make sure that sub inventory entered on DWB belongs to warehouse
                       specified on ship line, if not raise error.
                    3) If item is serialized make sure that user passes serial number information,
                       if not raise error.
                    4) If item is non-serialized  make sure that user passes Sub inventory information
                       else raise error.
                    5) If item is non-serialized and lot controlled make sure user passes
                       lot_number information else raise error.
                    6) If item is non-serialized and  revision controlled make sure user passes revision
                       information else raise error.
                    */
                    l_revision:=null;
                    l_shipped_serial_number  :=NULL;
                    l_lot_number             :=NULL;
                    l_sub_inventory          :=NULL;
                    l_SN_at_SO_new_SN_number :=FALSE;

                    if i.serial_number_control_code in (2,5,6) then

                      if nvl(p_product_txn_rec.source_serial_number,FND_API.G_MISS_CHAR)=FND_API.G_MISS_CHAR then
                        /* Validation 3 */
                        FND_MESSAGE.SET_NAME('CSD','CSD_API_SERIAL_NUM_REQD');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                      else
                        l_shipped_serial_number := p_product_txn_rec.source_serial_number;
                      end if;

                      begin
                        select Lot_Number, Revision, current_SubInventory_code
                        into   l_lot_number ,l_revision ,l_sub_inventory
                        from mtl_serial_numbers
                        where serial_number         = l_shipped_serial_number
                        AND inventory_item_id       = i.inventory_item_id
                        AND current_organization_id = i.organization_id;
                      exception
                        when no_data_found then
                          if (i.serial_number_control_code in (2,5)) then
                            /*Validation 1 */
                            FND_MESSAGE.SET_NAME('CSD','CSD_SERIAL_NUM_NOT_IN_INVORG');
                            FND_MESSAGE.SET_TOKEN('SERIAL_NUMBER',l_shipped_serial_number);
                            FND_MESSAGE.SET_TOKEN('INV_ORG',i.organization_code);
                            FND_MSG_PUB.ADD;
                            RAISE FND_API.G_EXC_ERROR;
                          else /*if Item is Serialied at SO then user may pass SN that does not resides in any warehouse */
                            l_SN_at_SO_new_SN_number :=TRUE;
                          end if;
                      end;
                    end if;  /*end if of serialized item */

                    if ( i.serial_number_control_code =1 or (i.serial_number_control_code=6 and l_SN_at_SO_new_SN_number=TRUE ) ) then
                      if nvl(p_product_txn_rec.sub_inventory ,FND_API.G_MISS_CHAR)=FND_API.G_MISS_CHAR then
                        /*Validation 4 */
                        FND_MESSAGE.SET_NAME('CSD','CSD_SUBINV_IS_REQD');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                      end if;

                      begin
                        SELECT msi.secondary_inventory_name
                        into   l_sub_inventory
                        FROM  mtl_secondary_inventories msi
                        where msi.organization_id = i.organization_id
                        AND  msi.secondary_inventory_name = p_product_txn_rec.sub_inventory
                        AND  NVL(msi.DISABLE_DATE,SYSDATE+1) > SYSDATE
                        AND  msi.QUANTITY_TRACKED = 1;

                      exception
                      When no_data_found then
                        /*Validation 2 */
                        FND_MESSAGE.SET_NAME('CSD','CSD_SUBINV_NOT_IN_INVORG');
                        FND_MESSAGE.SET_TOKEN('SUB_INV',p_product_txn_rec.sub_inventory);
                        FND_MESSAGE.SET_TOKEN('INV_ORG',i.organization_code);
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                      end;

                      if i.LOT_CONTROL_CODE =2 then
                        if nvl(p_product_txn_rec.lot_number,FND_API.G_MISS_CHAR)=FND_API.G_MISS_CHAR then
                          /*Validation 5 */
                          FND_MESSAGE.SET_NAME('CSD','CSD_LOT_NUMBER_REQD');
                          FND_MESSAGE.SET_TOKEN('ITEM',i.item_name);
                          FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                        else
                          l_lot_number:= p_product_txn_rec.lot_number;
                        end if;
                      end if;

                      if i.REVISION_QTY_CONTROL_CODE =2 then
                        if  nvl(p_product_txn_rec.revision,FND_API.G_MISS_CHAR)=FND_API.G_MISS_CHAR then
                          FND_MESSAGE.SET_NAME('CSD','CSD_ITEM_REVISION_REQD');
                          FND_MESSAGE.SET_TOKEN('ITEM',i.item_name);
                          FND_MSG_PUB.ADD;
                          RAISE FND_API.G_EXC_ERROR;
                        else
                          l_revision:=p_product_txn_rec.revision;
                        end if;
                      end if;
                    end if; /* end of non serialized item */

                    /* Till here all the validations are done now we can call update attribute API */
                    source_code := 'OE'; /*The only source code that should be used by the API */
                    changed_attributes(1).delivery_detail_id := i.delivery_detail_id;
                    changed_attributes(1).serial_number      := l_shipped_serial_number;
                    changed_attributes(1).revision           := l_revision ;
                    changed_attributes(1).lot_number         := l_lot_number;
                    changed_attributes(1).subinventory       := l_sub_inventory;
                    changed_attributes(1).shipped_quantity   := p_order_rec.shipped_quantity;

                    IF (g_debug > 0 ) THEN
                      csd_gen_utility_pvt.ADD('delivery_detail_id ='||changed_attributes(1).delivery_detail_id);
                      csd_gen_utility_pvt.ADD('serial_number      ='||changed_attributes(1).serial_number );
                      csd_gen_utility_pvt.ADD('Revision           ='||changed_attributes(1).revision );
                      csd_gen_utility_pvt.ADD('Lot number         ='||changed_attributes(1).lot_number );
                      csd_gen_utility_pvt.ADD('sub_inventory      ='||changed_attributes(1).subinventory );
                      csd_gen_utility_pvt.ADD('shipped_quantity   ='||changed_attributes(1).shipped_quantity );
                      csd_gen_utility_pvt.ADD('Calling Update_Shipping_Attributes');
                    END IF;

                    WSH_DELIVERY_DETAILS_PUB.Update_Shipping_Attributes(
                      p_api_version_number => 1.0,
                      p_init_msg_list      => p_init_msg_list,
                      p_commit             => p_commit,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_changed_attributes => changed_attributes,
                      p_source_code        => source_code);

                      IF (g_debug > 0 ) THEN
                        csd_gen_utility_pvt.ADD('x_return_status(Update_Shipping_Attributes )='||x_return_status);
                      END IF;

                      IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                        IF (g_debug > 0 ) THEN
                          csd_gen_utility_pvt.ADD('Update_Shipping_Attributes failed');
                        END IF;
                        RAISE fail_api;
                      END IF;

                  END IF;  /* end if of reservable type */

                EXCEPTION
                WHEN fail_api THEN
                  Wsh_Util_Core.get_messages('Y',
                                              x_msg_summary,
                                              x_msg_details,
                                              x_msg_count);
                  IF x_msg_count > 1 THEN
                    x_msg_data := x_msg_summary ||
                                  x_msg_details;
                  ELSE
                    x_msg_data := x_msg_summary;
                  END IF;

                  Debug('Error Msg from Update_Shipping_Attributes',
                    l_mod_name,
                    1);
                  Debug('x_msg_data = ' || x_msg_data,
                    l_mod_name,
                    1);
                  Fnd_Message.SET_NAME('CSD','CSD_UPDATE_SHIPPING_FAILED');
                  Fnd_Message.SET_TOKEN('ERR_MSG', x_msg_data);
                  Fnd_Msg_Pub.ADD;
                  RAISE Fnd_Api.G_EXC_ERROR;
                END;

--              END IF; --end of update_shipping_attributes

                BEGIN
                    Debug('i.delivery_id=' || i.delivery_id, l_mod_name, 1);

                    -- Values for Ship Confirming the delivery.
                    p_action_code             := 'CONFIRM'; -- The action code for ship confirm
                    p_delivery_id             := i.delivery_id; -- The delivery that needs to be confirmed
                    p_delivery_name           := TO_CHAR(i.delivery_id); -- The delivery name,
                    p_sc_action_flag          := 'S'; -- Ship entered quantity.

                    -- p_Sc_Intransit_flag needs to be set to 'Y' this as per bug 3676488 (Shipping)
                    -- This fix for bug# 3665544
                    p_sc_intransit_flag       := 'Y'; -- In transit flag is set to 'Y' closes the

                    -- pickup stop and sets the delivery in transit.
                    p_sc_close_trip_flag      := 'Y'; -- Close the trip after ship confirm

                    -- p_sc_trip_ship_method := ''; -- The ship method code
                    p_sc_defer_interface_flag := 'N'; -- defer interface

                    -- p_sc_report_set_id    := 6; -- check if it is seeded


        --bug#7675562
                  Debug('organization_id = '||i.organization_id,l_mod_name,1);

                  WSH_SHIPPING_PARAMS_GRP.Get_Shipping_Parameters(
                      i.organization_id,
                      l_ship_param_info,
                      x_return_status);

                  Debug('x_return_status(Get_Shipping_Parameters)='||x_return_status,l_mod_name,1);
                  Debug('DELIVERY_REPORT_SET_ID = '||l_ship_param_info.DELIVERY_REPORT_SET_ID,l_mod_name,1);

                  p_sc_report_set_id    := l_ship_param_info.DELIVERY_REPORT_SET_ID; -- check if it is seeded

                  IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS) THEN
                     Debug('Get_Shipping_Parameters failed',l_mod_name,1);
                     RAISE fail_api;
                  END IF;


                    Debug('Calling Delivery_Action ', l_mod_name, 1);

                    -- Call to WSH_DELIVERIES_PUB.Delivery_Action.
                    Wsh_Deliveries_Pub.Delivery_Action(p_api_version_number      => 1.0,
                                                       p_init_msg_list           => p_init_msg_list,
                                                       x_return_status           => x_return_status,
                                                       x_msg_count               => x_msg_count,
                                                       x_msg_data                => x_msg_data,
                                                       p_action_code             => p_action_code,
                                                       p_delivery_id             => p_delivery_id,
                                                       p_delivery_name           => p_delivery_name,
                                                       p_asg_trip_id             => p_asg_trip_id,
                                                       p_asg_trip_name           => p_asg_trip_name,
                                                       p_asg_pickup_stop_id      => p_asg_pickup_stop_id,
                                                       p_asg_pickup_loc_id       => p_asg_pickup_loc_id,
                                                       p_asg_pickup_loc_code     => p_asg_pickup_loc_code,
                                                       p_asg_pickup_arr_date     => p_asg_pickup_arr_date,
                                                       p_asg_pickup_dep_date     => p_asg_pickup_dep_date,
                                                       p_asg_dropoff_stop_id     => p_asg_dropoff_stop_id,
                                                       p_asg_dropoff_loc_id      => p_asg_dropoff_loc_id,
                                                       p_asg_dropoff_loc_code    => p_asg_dropoff_loc_code,
                                                       p_asg_dropoff_arr_date    => p_asg_dropoff_arr_date,
                                                       p_asg_dropoff_dep_date    => p_asg_dropoff_dep_date,
                                                       p_sc_action_flag          => p_sc_action_flag,
                                                       p_sc_intransit_flag       => p_sc_intransit_flag,
                                                       p_sc_close_trip_flag      => p_sc_close_trip_flag,
                                                       p_sc_create_bol_flag      => p_sc_create_bol_flag,
                                                       p_sc_stage_del_flag       => p_sc_stage_del_flag,
                                                       p_sc_trip_ship_method     => p_sc_trip_ship_method,
                                                       p_sc_actual_dep_date      => p_sc_actual_dep_date,
                                                       p_sc_report_set_id        => p_sc_report_set_id,
                                                       p_sc_report_set_name      => p_sc_report_set_name,
                                                       p_sc_defer_interface_flag => p_sc_defer_interface_flag,
                                                       p_wv_override_flag        => p_wv_override_flag,
                                                       x_trip_id                 => x_trip_id,
                                                       x_trip_name               => x_trip_name);

                    Debug('x_return_status(Delivery_Action )=' ||
                          x_return_status,
                          l_mod_name,
                          1);

                    IF (x_return_status <> Wsh_Util_Core.G_RET_STS_SUCCESS)
                    THEN
                        Debug('Delivery_Action failed', l_mod_name, 1);
                        RAISE fail_api;
                    END IF;
                EXCEPTION
                    WHEN fail_api THEN
                        Wsh_Util_Core.get_messages('Y',
                                                   x_msg_summary,
                                                   x_msg_details,
                                                   x_msg_count);
                        IF x_msg_count > 1
                        THEN
                            x_msg_data := x_msg_summary || x_msg_details;
                        ELSE
                            x_msg_data := x_msg_summary;
                        END IF;
                        Debug('Error Msg from Delivery_Action',
                              l_mod_name,
                              1);
                        Debug('x_msg_data = ' || x_msg_data, l_mod_name, 1);
                        -- Ignore if it is a warning
                        -- bug#8269688, FP of bug#7659800, subhat
                        --IF (x_return_status <>
                        --   Wsh_Util_Core.G_RET_STS_WARNING)
                        IF (x_return_status <> WSH_UTIL_CORE.G_RET_STS_SUCCESS)
                        THEN
                            begin
			      select 'N'
			      into   l_shipped_flag
			      from wsh_delivery_details wdd
			      where wdd.delivery_detail_id = i.delivery_detail_id
				    and wdd.released_status <> 'C';
			    exception
			      when no_data_found then
			      l_shipped_flag :='Y';
			    end;
			    if l_shipped_flag = 'N' then
			      FND_MESSAGE.SET_NAME('CSD','CSD_SHIP_CONFIRM_FAILED');
			      FND_MESSAGE.SET_TOKEN('ERR_MSG',x_msg_data);
			      FND_MSG_PUB.ADD;
			      RAISE FND_API.G_EXC_ERROR;
			    end if;
                        END IF;
                        -- end bug#8269688, FP of bug#7659800, subhat
                        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
                END; -- end of delivery action

            END LOOP; -- At the end of processing all the delivery id for an Order
        END IF; -- end of all actions

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
		  Debug('In EXC_ERROR in process_sales_order', l_mod_name, 1);
            ROLLBACK TO process_sales_order;

            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
		  Debug('In EXC_UNEXP_ERROR in process_sales_order', l_mod_name, 1);
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO process_sales_order;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
		  Debug('In OTHERS in process_sales_order' || sqlerrm, l_mod_name, 1);
            ROLLBACK TO process_sales_order;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END process_sales_order;

    /*------------------------------------------------------------------*/
    /* Procedure name: Create_product_txn                               */
    /* Description   : Procedure to create product transaction lines    */
    /*               1. It may from the ON-INSERT trigger in repair     */
    /*                  order form for creating ptoduct txn manually.   */
    /*               2. It may be also called from create_default_txn   */
    /*                  API to create product txn at the time creating  */
    /*                  repair orders                                   */
    /*------------------------------------------------------------------*/

    PROCEDURE create_product_txn(p_api_version      IN NUMBER,
                                 p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                 p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                 p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                 x_product_txn_rec  IN OUT NOCOPY PRODUCT_TXN_REC,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_PRODUCT_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(2000);
        l_msg_index              NUMBER;
        l_product_transaction_id NUMBER := NULL;
        l_serial_flag            BOOLEAN := FALSE;
        l_dummy                  VARCHAR2(1);
        l_check                  VARCHAR2(1);
        l_Charges_Rec            Cs_Charge_Details_Pub.Charges_Rec_type;
        l_estimate_Rec           Cs_Charge_Details_Pub.Charges_Rec_type;
        l_estimate_detail_id     NUMBER := NULL;
        x_estimate_detail_id     NUMBER := NULL;
        l_incident_id            NUMBER := NULL;
        l_order_rec              OM_INTERFACE_REC;
        l_reference_number       VARCHAR2(30) := '';
        l_contract_number        VARCHAR2(120) := '';
        l_bus_process_id         NUMBER := NULL;
        l_repair_type_ref        VARCHAR2(3) := '';
        l_line_type_id           NUMBER := NULL;
        l_txn_billing_type_id    NUMBER := NULL;
        l_party_id               NUMBER := NULL;
        l_account_id             NUMBER := NULL;
        l_order_header_id        NUMBER := NULL;
        l_release_status         VARCHAR2(10) := '';
        l_curr_code              VARCHAR2(10) := '';
        l_picking_rule_id        NUMBER := NULL;
        l_ship_qty               NUMBER := NULL;
        l_line_category_code     VARCHAR2(30) := '';
        l_ship_from_org_id       NUMBER := NULL;
        l_order_line_id          NUMBER := NULL;
        l_coverage_id            NUMBER := NULL;
        -- Bugfix 3617932, vkjain.
        -- Increasing the column length to 150
        -- l_coverage_name          VARCHAR2(150) := ''; -- Commented for bugfix 3617932
        l_txn_group_id        NUMBER := NULL;
        l_unit_selling_price  NUMBER := NULL;
        l_transaction_type_id NUMBER := NULL;
        l_order_category_code VARCHAR2(30);
        l_add_to_same_order   BOOLEAN;
        l_orig_src_reference  VARCHAR2(30);
        l_orig_src_header_id  NUMBER;
        l_orig_src_line_id    NUMBER;
        l_orig_po_num         VARCHAR2(50);
        l_rev_ctl_code        mtl_system_items.revision_qty_control_code%TYPE;
        l_booked_flag         oe_order_headers_all.booked_flag%TYPE;

        --taklam
        l_Line_Tbl_Type         OE_ORDER_PUB.Line_Tbl_Type;
        x_Line_Tbl_Type         OE_ORDER_PUB.Line_Tbl_Type;
        l_p_ship_from_org_id     NUMBER;
        l_project_count          NUMBER;

        l_sr_account_id        NUMBER; -- swai: bug 6001057

        create_order EXCEPTION;
        book_order EXCEPTION;
        release_order EXCEPTION;
        ship_order EXCEPTION;

        --Bug fix for 3399883 [
        l_no_contract_bp_vldn VARCHAR2(10);
        --]

        CURSOR order_rec(p_incident_id IN NUMBER) IS
            SELECT customer_id, account_id
              FROM cs_incidents_all_b
             WHERE incident_id = p_incident_id;

        CURSOR estimate(p_rep_line_id IN NUMBER) IS
            SELECT estimate_detail_id, object_version_number
              FROM cs_estimate_details
             WHERE source_id = p_rep_line_id
               AND source_code = 'DR'
               AND interface_to_oe_flag = 'N'
               AND order_header_id IS NULL
               AND order_line_id IS NULL;

        --taklam
        CURSOR project_cu(l_project_id NUMBER, l_p_ship_from_org_id NUMBER) IS
        SELECT COUNT(*) p_count
        FROM PJM_PROJECTS_ORG_V
        WHERE project_id = l_project_id and inventory_organization_id = l_p_ship_from_org_id;

        CURSOR order_line_cu(l_est_detail_id NUMBER) is
        SELECT b.order_line_id, a.ship_from_org_id
        FROM oe_order_lines_all a, cs_estimate_details b
        WHERE a.line_id = b.order_line_id
        AND  b.estimate_detail_id = l_est_detail_id;

        -- swai: bug 6001057
        CURSOR sr_account_cu (l_repair_line_id NUMBER) is
        SELECT account_id
        FROM cs_incidents_all_b cs, csd_repairs csd
        WHERE cs.incident_id = csd.incident_id
          AND repair_line_id = l_repair_line_id;

        --R12 Development Changes Begin
        CURSOR cur_pick_rules(p_pick_rule_id NUMBER) IS
            SELECT 'x'
              FROM wsh_picking_rules
             WHERE picking_rule_id = p_pick_rule_id
               AND SYSDATE BETWEEN NVL(start_Date_Active, SYSDATE) AND
                   NVL(end_Date_active, SYSDATE + 1);
        --R12 Development Changes End

        -- Variables used in FND Log
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_process_pvt.create_product_txn';
        l_tmp_char    VARCHAR2(1); --R12 Development Changes
      /* R12 SN reservations integration change Begin */
      l_ItemAttributes Csd_Logistics_Util.ItemAttributes_Rec_Type;
      l_auto_reserve_profile  VARCHAR2(10);
      l_srl_reservation_id NUMBER;
      l_serial_rsv_rec CSD_LOGISTICS_UTIL.CSD_SERIAL_RESERVE_REC_TYPE ;
      /* R12 SN reservations integration change End */

      -- swai bug 7572247/7628204: cursor to default account address for SR account
      CURSOR c_sr_primary_account_address(p_incident_id NUMBER, p_site_use_type VARCHAR2)
      IS
            select distinct
                   hp.party_site_id
              from hz_party_sites_v hp,
                   hz_parties hz,
                   hz_cust_acct_sites_all hca,
                   hz_cust_site_uses_all hcsu,
                   cs_incidents_all_b cs
             where hcsu.site_use_code = p_site_use_type
              and  cs.incident_id = p_incident_id
              and  hp.status = 'A'
              and  hcsu.status = 'A'
              and  hp.party_id = hz.party_id
              and  hca.party_site_id = hp.party_site_id
              and  hca.cust_account_id = cs.account_id
              and  hcsu.cust_acct_site_id = hca.cust_acct_site_id
              and  hca.org_id = cs.org_id
              and  hcsu.primary_flag = 'Y'
              and rownum = 1;

    BEGIN
        -- Debug message
        Debug('At the Beginning of create_product_txn', l_mod_name, 1);

        -- Standard Start of API savepoint
        SAVEPOINT create_product_txn;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Api body starts

        -- Dump the IN parameters in the log file
        -- if the debug level > 5
        IF (g_debug > 5)
        THEN
            Csd_Gen_Utility_Pvt.dump_prod_txn_rec(p_prod_txn_rec => x_product_txn_rec);
        END IF;

        Debug('********* Check reqd parameter ***************',
              l_mod_name,
              1);
        Debug('Repair Line ID      =' || x_product_txn_rec.repair_line_id,
              l_mod_name,
              1);
        Debug('Action Code         =' || x_product_txn_rec.action_code,
              l_mod_name,
              1);
        Debug('Action Type         =' || x_product_txn_rec.action_type,
              l_mod_name,
              1);
        Debug('Txn_billing_type_id =' ||
              x_product_txn_rec.txn_billing_type_id,
              l_mod_name,
              1);

        -- Check the required parameter(txn_billing_type_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.txn_billing_type_id,
                                          p_param_name  => 'TXN_BILLING_TYPE_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(inventory_item_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.inventory_item_id,
                                          p_param_name  => 'INVENTORY_ITEM_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(unit_of_measure_code)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.unit_of_measure_code,
                                          p_param_name  => 'UNIT_OF_MEASURE_CODE',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(quantity)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.quantity,
                                          p_param_name  => 'QUANTITY',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(price_list_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.price_list_id,
                                          p_param_name  => 'PRICE_LIST_ID',
                                          p_api_name    => l_api_name);

        Debug('Validate repair line id', l_mod_name, 1);

        -- Validate the repair line ID if it exists in csd_repairs
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => x_product_txn_rec.repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('Validate action type', l_mod_name, 1);

        -- Validate the Action Type if it exists in fnd_lookups
        IF NOT
            (Csd_Process_Util.Validate_action_type(p_action_type => x_product_txn_rec.action_type))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('Validate action code', l_mod_name, 1);

        -- Validate the repair line ID if it exists in fnd_lookups
        IF NOT
            (Csd_Process_Util.Validate_action_code(p_action_code => x_product_txn_rec.action_code))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        --R12 Development changes begin
        Debug('Validating picking rule if passed[' ||
              x_producT_txn_rec.picking_rule_id || ']',
              l_mod_name,
              1);
        IF (x_producT_txn_rec.picking_rule_id <> NULL)
        THEN
            OPEN cur_pick_rules(x_producT_txn_rec.picking_rule_id);
            FETCH cur_pick_rules
                INTO l_tmp_char;
            IF (cur_pick_rules%NOTFOUND)
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_INV_PICK_RULE');
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;
        --R12 Development changes End
        Debug('Validate product txn qty', l_mod_name, 1);
        Debug('x_product_txn_rec.quantity =' || x_product_txn_rec.quantity,
              l_mod_name,
              1);

        -- Validate if the product txn quantity (customer product only)
        -- is not exceeding the repair order quantity
        -- swai: bug 5931926 - 12.0.2 do not validate quantity for third party lines
        -- since multiple parts can be shipped out.
        IF x_product_txn_rec.action_code = 'CUST_PROD' AND
           x_product_txn_rec.action_type not in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')
        THEN
            Csd_Process_Util.Validate_quantity(p_action_type    => x_product_txn_rec.action_type,
                                               p_repair_line_id => x_product_txn_rec.repair_line_id,
                                               p_prod_txn_qty   => x_product_txn_rec.quantity,
                                               x_return_status  => x_return_status);
            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                Debug('Validate_Quantity failed ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        Debug('Validate product txn status', l_mod_name, 1);
        Debug('x_product_txn_rec.PROD_TXN_STATUS =' ||
              x_product_txn_rec.PROD_TXN_STATUS,
              l_mod_name,
              1);

        -- Validate the PROD_TXN_STATUS if it exists in fnd_lookups
        IF (x_product_txn_rec.PROD_TXN_STATUS IS NOT NULL) AND
           (x_product_txn_rec.PROD_TXN_STATUS <> Fnd_Api.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT 'X'
                  INTO l_check
                  FROM fnd_lookups
                 WHERE lookup_type = 'CSD_PRODUCT_TXN_STATUS'
                   AND lookup_code = x_product_txn_rec.PROD_TXN_STATUS;
            EXCEPTION
                WHEN OTHERS THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_ERR_PROD_TXN_STATUS');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        -- Get service request from csd_repairs table
        -- using repair order
        BEGIN
            SELECT incident_id,
                   original_source_reference,
                   original_source_header_id,
                   original_source_line_id
              INTO l_incident_id,
                   l_orig_src_reference,
                   l_orig_src_header_id,
                   l_orig_src_line_id
              FROM csd_repairs
             WHERE repair_line_id = x_product_txn_rec.repair_line_id;
        EXCEPTION
            WHEN OTHERS THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      x_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        Debug('l_incident_id    =' || l_incident_id, l_mod_name, 1);

        -- Get the business process id
        -- Forward bug fix # 2756313
        -- l_bus_process_id := CSD_PROCESS_UTIL.GET_BUS_PROCESS(l_incident_id);

        l_bus_process_id := Csd_Process_Util.GET_BUS_PROCESS(x_product_txn_rec.repair_line_id);

        Debug('l_bus_process_id =' || l_bus_process_id, l_mod_name, 1);

        IF l_bus_process_id < 0
        THEN
            IF NVL(x_product_txn_rec.business_process_id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN
                l_bus_process_id := x_product_txn_rec.business_process_id;
            ELSE
                Debug('Business process Id does not exist ', l_mod_name, 1);
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        Debug('Getting the Coverage and txn Group Id', l_mod_name, 1);
        Debug('contract_line_id =' || x_product_txn_rec.contract_id,
              l_mod_name,
              1);

        IF (x_product_txn_rec.transaction_type_id IS NULL) OR
           (x_product_txn_rec.transaction_type_id = Fnd_Api.G_MISS_NUM)
        THEN
            BEGIN
                SELECT transaction_type_id
                  INTO l_transaction_type_id
                  FROM cs_txn_billing_types
                 WHERE txn_billing_type_id =
                       x_product_txn_rec.txn_billing_type_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Debug('No Row found for the txn_billing_type_id=' ||
                          TO_CHAR(l_txn_billing_type_id),
                          l_mod_name,
                          1);
                WHEN OTHERS THEN
                    Debug('When others exception at - Transaction type id',
                          l_mod_name,
                          1);
            END;
            x_product_txn_rec.transaction_type_id := l_transaction_type_id;
            Debug('x_product_txn_rec.transaction_type_id :' ||
                  TO_CHAR(x_product_txn_rec.transaction_type_id),
                  l_mod_name,
                  1);
        END IF;

        -- Get the coverage details from the contract
		/******************************contract changes
        IF NVL(x_product_txn_rec.contract_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            BEGIN
                --Bug fix for 3399883 [
                l_no_contract_bp_vldn := NVL(Fnd_Profile.value('CSD_NO_CONTRACT_BP_VLDN'),
                                             'N');

                IF (l_no_contract_bp_vldn = 'Y')
                THEN

                    SELECT cov.actual_coverage_id,
                           -- cov.coverage_name, -- Commented for bugfix 3617932
                           ent.txn_group_id
                      INTO l_coverage_id,
                           -- l_coverage_name, -- Commented for bugfix 3617932
                           l_txn_group_id
                      FROM oks_ent_coverages_v  cov,
                           oks_ent_txn_groups_v ent
                     WHERE cov.contract_line_id =
                           x_product_txn_rec.contract_id
                       AND cov.actual_coverage_id = ent.coverage_id;
                ELSE
                    --]

                    SELECT cov.actual_coverage_id,
                           -- cov.coverage_name,  -- Commented for bugfix 3617932
                           ent.txn_group_id
                      INTO l_coverage_id,
                           -- l_coverage_name, -- Commented for bugfix 3617932
                           l_txn_group_id
                      FROM oks_ent_coverages_v  cov,
                           oks_ent_txn_groups_v ent
                     WHERE cov.contract_line_id =
                           x_product_txn_rec.contract_id
                       AND cov.actual_coverage_id = ent.coverage_id
                       AND ent.business_process_id = l_bus_process_id;
                    --Bug fix for 3399883 [
                END IF;
                --]
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_API_CONTRACT_MISSING');
                    Fnd_Message.SET_TOKEN('CONTRACT_LINE_ID',
                                          x_product_txn_rec.contract_id);
                    Fnd_Msg_Pub.ADD;
                    Debug('Contract Line Id missing', l_mod_name, 1);
                    RAISE Fnd_Api.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                    Debug('Too many Contract Line', l_mod_name, 1);
            END;
            x_product_txn_rec.coverage_id           := l_coverage_id;
            x_product_txn_rec.coverage_txn_group_id := l_txn_group_id;

            Debug('l_coverage_id  =' || l_coverage_id, l_mod_name, 1);
            Debug('l_txn_group_id =' || l_txn_group_id, l_mod_name, 1);
        END IF;
		*******************************/

        IF l_incident_id IS NOT NULL
        THEN
            -- swai: bug 5931926 - 12.0.2 3rd party logistics
            -- only set order header info to SR party and account
            -- if it is not specified on the bill-to for the txn line.
            IF (nvl(l_Charges_Rec.bill_to_account_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) OR
               (nvl(l_Charges_Rec.bill_to_party_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) THEN
               OPEN order_rec(l_incident_id);
               FETCH order_rec
                   INTO l_party_id, l_account_id;
               IF (order_rec%NOTFOUND OR l_party_id IS NULL)
               THEN
                   Fnd_Message.SET_NAME('CSD', 'CSD_API_PARTY_MISSING');
                   Fnd_Message.SET_TOKEN('INCIDENT_ID', l_incident_id);
                   Fnd_Msg_Pub.ADD;
                   RAISE Fnd_Api.G_EXC_ERROR;
               END IF;
               IF order_rec%ISOPEN
               THEN
                   CLOSE order_rec;
               END IF;
            ELSE
               l_party_id := l_Charges_Rec.bill_to_party_id;
               l_account_id := l_Charges_Rec.bill_to_account_id;
            END IF;
        END IF;

        Debug('l_party_id                            =' || l_party_id,
              l_mod_name,
              1);
        Debug('l_account_id                          =' || l_account_id,
              l_mod_name,
              1);
        Debug('x_product_txn_rec.txn_billing_type_id =' ||
              x_product_txn_rec.txn_billing_type_id,
              l_mod_name,
              1);
        Debug('x_product_txn_rec.organization_id     =' ||
              x_product_txn_rec.organization_id,
              l_mod_name,
              1);

        -- Derive the line type and line category code
        -- from the transaction billing type
        Csd_Process_Util.GET_LINE_TYPE(p_txn_billing_type_id => x_product_txn_rec.txn_billing_type_id,
                                       p_org_id              => x_product_txn_rec.organization_id,
                                       x_line_type_id        => l_line_type_id,
                                       x_line_category_code  => l_line_category_code,
                                       x_return_status       => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('l_line_type_id                  =' || l_line_type_id,
              l_mod_name,
              1);
        Debug('l_line_category_code            =' || l_line_category_code,
              l_mod_name,
              1);
        Debug('x_product_txn_rec.price_list_id =' ||
              x_product_txn_rec.price_list_id,
              l_mod_name,
              1);

        -- If line_type_id Or line_category_code is null
        -- then raise error
        IF (l_line_type_id IS NULL OR l_line_category_code IS NULL)
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_LINE_TYPE_MISSING');
            Fnd_Message.SET_TOKEN('TXN_BILLING_TYPE_ID',
                                  x_product_txn_rec.txn_billing_type_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Get the currency code from the price list if it is null or g_miss
        IF NVL(x_product_txn_rec.price_list_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            BEGIN
                SELECT currency_code
                  INTO l_curr_code
                  FROM oe_price_lists
                 WHERE price_list_id = x_product_txn_rec.price_list_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_API_INV_PRICE_LIST_ID');
                    Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                          x_product_txn_rec.price_list_id);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                    Debug('Too many currency_codes', l_mod_name, 1);
            END;
        END IF;

        Debug('l_curr_code          =' || l_curr_code, l_mod_name, 1);

        -- If l_curr_code is null then raise error
        IF l_curr_code IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_CURR_CODE');
            Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                  x_product_txn_rec.price_list_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        l_serial_flag := Csd_Process_Util.Is_item_serialized(x_product_txn_rec.inventory_item_id);

        -- swai: bug 5931926 - 12.0.2 3rd party logistics
        -- Instead of adding 3rd party action types to if-then statement,
        -- we are commenting the code out altogether.  Currently,
        -- if conditions do not allow any product transaction lines
        -- through except walk-in-receipt which is no longer supported.
        -- We should allow RMA line creation without Serial number for
        -- all action types.
        /*****
        -- Serial Number required if the item is serialized
        IF l_serial_flag AND
          -- changing from serial_number to source_serial_number 11.5.10
           NVL(x_product_txn_rec.source_serial_number, Fnd_Api.G_MISS_CHAR) =
           Fnd_Api.G_MISS_CHAR AND
           x_product_txn_rec.action_type NOT IN ('SHIP', 'WALK_IN_ISSUE') AND
           (x_product_txn_rec.action_code <> 'LOANER' AND
           x_product_txn_rec.action_type <> 'RMA')
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_SERIAL_NUM_MISSING');
            Fnd_Message.SET_TOKEN('INVENTORY_ITEM_ID',
                                  x_product_txn_rec.inventory_item_id);
            Fnd_Msg_Pub.ADD;
            Debug('Serial Number missing for inventory_item_id =' ||
                  x_product_txn_rec.inventory_item_id,
                  l_mod_name,
                  1);
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
        *****/

        IF (x_product_txn_rec.new_order_flag = 'N')
        THEN
          -- Fix for bug# 4913791
          IF ( x_product_txn_rec.interface_to_om_flag = 'Y' ) THEN
            x_product_txn_rec.add_to_order_flag := 'Y';
            x_product_txn_rec.order_header_id   := x_product_txn_rec.add_to_order_id;
          ELSE
            x_product_txn_rec.add_to_order_flag := 'F';
            x_product_txn_rec.order_header_id := FND_API.G_MISS_NUM;
          END IF;

        ELSIF (x_product_txn_rec.new_order_flag = 'Y')
        THEN
            x_product_txn_rec.add_to_order_flag := 'F';
            x_product_txn_rec.order_header_id   := Fnd_Api.G_MISS_NUM;
        END IF;

        Debug('x_product_txn_rec.new_order_flag =' ||
              x_product_txn_rec.new_order_flag,
              l_mod_name,
              1);
        Debug('x_product_txn_rec.add_to_order_flag =' ||
              x_product_txn_rec.add_to_order_flag,
              l_mod_name,
              1);
        Debug('x_product_txn_rec.order_header_id =' ||
              x_product_txn_rec.order_header_id,
              l_mod_name,
              1);

        -- assigning values for the charge record
        x_product_txn_rec.incident_id         := l_incident_id;
        x_product_txn_rec.business_process_id := l_bus_process_id;
        x_product_txn_rec.line_type_id        := l_line_type_id;
        x_product_txn_rec.currency_code       := l_curr_code;
        x_product_txn_rec.line_category_code  := l_line_category_code;

        -- swai bug 7572247/7628204: default account primary bill-to and ship to
        IF ((l_incident_id is not NULL) AND
            (nvl(fnd_profile.value('CSD_DEFAULT_SR_ACCT_ADDR_FOR_LOGISTICS'), 'N') = 'Y'))
        THEN

            IF ((nvl(x_product_txn_rec.bill_to_account_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) AND
                (nvl(x_product_txn_rec.invoice_to_org_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM))
            THEN
                OPEN c_sr_primary_account_address (l_incident_id, 'BILL_TO');
                FETCH c_sr_primary_account_address INTO x_product_txn_rec.invoice_to_org_id;
                IF c_sr_primary_account_address%ISOPEN THEN
                    CLOSE c_sr_primary_account_address;
                END IF;
            END IF;

            IF ((nvl(x_product_txn_rec.ship_to_account_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) AND
                (nvl(x_product_txn_rec.ship_to_org_id, FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM))
            THEN
                OPEN c_sr_primary_account_address (l_incident_id, 'SHIP_TO');
                FETCH c_sr_primary_account_address INTO x_product_txn_rec.ship_to_org_id;
                IF c_sr_primary_account_address%ISOPEN THEN
                    CLOSE c_sr_primary_account_address;
                END IF;
            END IF;
        END IF;
        -- end swai: bug 7572247/7628204

        Debug('Convert product txn rec to charges rec', l_mod_name, 1);

        -- Convert the product txn record to
        -- charge record
        Csd_Process_Util.CONVERT_TO_CHG_REC(p_prod_txn_rec  => x_product_txn_rec,
                                            x_charges_rec   => l_Charges_Rec,
                                            x_return_status => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('Call process_charge_lines to create charge lines ',
              l_mod_name,
              1);
        Debug('x_product_txn_rec.transaction_type_id :' ||
              TO_CHAR(x_product_txn_rec.transaction_type_id),
              l_mod_name,
              1);
        Debug('l_Charges_Rec.transaction_type_id :' ||
              TO_CHAR(l_Charges_Rec.transaction_type_id),
              l_mod_name,
              1);

        PROCESS_CHARGE_LINES(p_api_version        => 1.0,
                             p_commit             => Fnd_Api.g_false,
                             p_init_msg_list      => Fnd_Api.g_true,
                             p_validation_level   => Fnd_Api.g_valid_level_full,
                             p_action             => 'CREATE',
                             p_Charges_Rec        => l_Charges_Rec,
                             x_estimate_detail_id => x_estimate_detail_id,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        Debug('NEW ESTIMATE DETAIL ID    =' || x_estimate_detail_id,
              l_mod_name,
              1);
        Debug('Call csd_product_transactions_pkg.insert_row to insert prod txns',
              l_mod_name,
              1);

        -- Note (TTRV) at this point I would like to derive values for the new columns, every column is not
        -- use full for regular repair orders, some of the columns are used by regurlar repair orders but
        -- they need not be filled at the time of creation of product transaction record. Some of the columns
        -- are updated by update programs.
        -- Please come back and verify that for repair types, Exchange, Advance Exchange, Replacement
        -- non-source columns are picked from UI. These comments are added by saupadhy TTRV
        Csd_Product_Transactions_Pkg.INSERT_ROW(px_PRODUCT_TRANSACTION_ID  => x_product_txn_rec.PRODUCT_TRANSACTION_ID,
                                                p_REPAIR_LINE_ID           => x_product_txn_rec.REPAIR_LINE_ID,
                                                p_ESTIMATE_DETAIL_ID       => x_estimate_detail_id,
                                                p_ACTION_TYPE              => x_product_txn_rec.ACTION_TYPE,
                                                p_ACTION_CODE              => x_product_txn_rec.ACTION_CODE,
                                                p_LOT_NUMBER               => x_product_txn_rec.LOT_NUMBER,
                                                p_SUB_INVENTORY            => x_product_txn_rec.SUB_INVENTORY,
                                                p_INTERFACE_TO_OM_FLAG     => 'N',
                                                p_BOOK_SALES_ORDER_FLAG    => 'N',
                                                p_RELEASE_SALES_ORDER_FLAG => 'N',
                                                p_SHIP_SALES_ORDER_FLAG    => 'N',
                                                p_PROD_TXN_STATUS          => 'ENTERED',
                                                p_PROD_TXN_CODE            => x_product_txn_rec.PROD_TXN_CODE,
                                                p_LAST_UPDATE_DATE         => SYSDATE,
                                                p_CREATION_DATE            => SYSDATE,
                                                p_LAST_UPDATED_BY          => Fnd_Global.USER_ID,
                                                p_CREATED_BY               => Fnd_Global.USER_ID,
                                                p_LAST_UPDATE_LOGIN        => Fnd_Global.USER_ID,
                                                p_ATTRIBUTE1               => x_product_txn_rec.ATTRIBUTE1,
                                                p_ATTRIBUTE2               => x_product_txn_rec.ATTRIBUTE2,
                                                p_ATTRIBUTE3               => x_product_txn_rec.ATTRIBUTE3,
                                                p_ATTRIBUTE4               => x_product_txn_rec.ATTRIBUTE4,
                                                p_ATTRIBUTE5               => x_product_txn_rec.ATTRIBUTE5,
                                                p_ATTRIBUTE6               => x_product_txn_rec.ATTRIBUTE6,
                                                p_ATTRIBUTE7               => x_product_txn_rec.ATTRIBUTE7,
                                                p_ATTRIBUTE8               => x_product_txn_rec.ATTRIBUTE8,
                                                p_ATTRIBUTE9               => x_product_txn_rec.ATTRIBUTE9,
                                                p_ATTRIBUTE10              => x_product_txn_rec.ATTRIBUTE10,
                                                p_ATTRIBUTE11              => x_product_txn_rec.ATTRIBUTE11,
                                                p_ATTRIBUTE12              => x_product_txn_rec.ATTRIBUTE12,
                                                p_ATTRIBUTE13              => x_product_txn_rec.ATTRIBUTE13,
                                                p_ATTRIBUTE14              => x_product_txn_rec.ATTRIBUTE14,
                                                p_ATTRIBUTE15              => x_product_txn_rec.ATTRIBUTE15,
                                                p_CONTEXT                  => x_product_txn_rec.CONTEXT,
                                                p_OBJECT_VERSION_NUMBER    => 1,
                                                P_SOURCE_SERIAL_NUMBER     => x_product_txn_rec.source_serial_number,
                                                P_SOURCE_INSTANCE_ID       => x_product_txn_rec.source_instance_Id,
                                                P_NON_SOURCE_SERIAL_NUMBER => x_product_txn_rec.non_source_serial_number,
                                                P_NON_SOURCE_INSTANCE_ID   => x_product_txn_rec.non_source_instance_id,
                                                P_REQ_HEADER_ID            => x_product_txn_rec.Req_Header_Id,
                                                P_REQ_LINE_ID              => x_product_txn_rec.Req_Line_Id,
                                                P_ORDER_HEADER_ID          => x_Product_Txn_Rec.Order_Header_Id,
                                                P_ORDER_LINE_ID            => x_Product_Txn_Rec.Order_Line_Id,
                                                P_PRD_TXN_QTY_RECEIVED     => x_product_txn_rec.Prd_Txn_Qty_Received,
                                                P_PRD_TXN_QTY_SHIPPED      => x_product_txn_rec.Prd_Txn_Qty_Shipped,
                                                P_SUB_INVENTORY_RCVD       => x_product_txn_rec.Sub_Inventory_Rcvd,
                                                P_LOT_NUMBER_RCVD          => x_product_txn_rec.Lot_Number_Rcvd,
                                                P_LOCATOR_ID               => x_product_txn_rec.Locator_Id,
                                                --R12 Development Changes
                                                p_picking_rule_id => x_product_txn_rec.picking_rule_id,
                                                P_PROJECT_ID               => x_product_txn_rec.project_id,
                                                P_TASK_ID                  => x_product_txn_rec.task_id,
                                                P_UNIT_NUMBER              => x_product_txn_rec.unit_number,
                                                P_INTERNAL_PO_HEADER_ID    => x_product_txn_rec.internal_po_header_id);  -- swai: bug 6148019


        Debug('NEW PRODUCT TXN ID = ' ||
              x_product_txn_rec.PRODUCT_TRANSACTION_ID,
              l_mod_name,
              1);

        UPDATE csd_repairs
           SET ro_txn_status = 'CHARGE_ENTERED'
         WHERE repair_line_id = x_product_txn_rec.REPAIR_LINE_ID;
        IF SQL%NOTFOUND
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_ERR_REPAIRS_UPDATE');
            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                  x_product_txn_rec.repair_line_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Process the product txn only if the process_flag = 'Y'
        -- Else skip to the end and return the control to calling program
        IF x_product_txn_rec.process_txn_flag = 'Y'
        THEN

            -- Assigning values for the order record
            l_order_rec.incident_id := l_incident_id;
            l_order_rec.party_id    := l_party_id;
            l_order_rec.account_id  := l_account_id;
            l_order_rec.org_id      := Cs_Std.get_item_valdn_orgzn_id;

            -- Interface the charge line to OM if the flag is checked
            IF x_product_txn_rec.interface_to_om_flag = 'Y'
            THEN

                BEGIN

                    -- Define savepoint
                    SAVEPOINT create_sales_order;

                    BEGIN
                        SELECT revision_qty_control_code
                          INTO l_rev_ctl_code
                          FROM mtl_system_items
                         WHERE organization_id =
                               Cs_Std.get_item_valdn_orgzn_id
                           AND inventory_item_id =
                               x_product_txn_rec.inventory_item_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_INVALID_INVENTORY_ITEM');
                            Fnd_Msg_Pub.ADD;
                            RAISE CREATE_ORDER;
                    END;

                    IF l_rev_ctl_code = 2
                    THEN
                        BEGIN
                            SELECT 'x'
                              INTO l_dummy
                              FROM mtl_item_revisions
                             WHERE inventory_item_id =
                                   x_product_txn_rec.inventory_item_id
                               AND organization_id =
                                   Cs_Std.get_item_valdn_orgzn_id
                               AND revision = x_product_txn_rec.revision;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_INVALID_REVISION');
                                Fnd_Msg_Pub.ADD;
                                RAISE CREATE_ORDER;
                        END;
                    END IF;

                    Debug('Call process_sales_order to create SO',
                          l_mod_name,
                          1);
                    Debug('l_order_rec.incident_id =' ||
                          l_order_rec.incident_id,
                          l_mod_name,
                          1);
                    Debug('l_order_rec.party_id    =' ||
                          l_order_rec.party_id,
                          l_mod_name,
                          1);
                    Debug('l_order_rec.account_id  =' ||
                          l_order_rec.account_id,
                          l_mod_name,
                          1);

                  --taklam
                     if (x_product_txn_rec.unit_number) is not null then
                        FND_PROFILE.PUT('CSD_UNIT_NUMBER', x_product_txn_rec.unit_number);
                     end if;

                    PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                        p_commit           => Fnd_Api.g_false,
                                        p_init_msg_list    => Fnd_Api.g_true,
                                        p_validation_level => Fnd_Api.g_valid_level_full,
                                        p_action           => 'CREATE',
                                        p_order_rec        => l_order_rec,
                                        x_return_status    => x_return_status,
                                        x_msg_count        => x_msg_count,
                                        x_msg_data         => x_msg_data);

                     if (x_product_txn_rec.unit_number) is not null then
                        FND_PROFILE.PUT('CSD_UNIT_NUMBER', null);
                     end if;

                    Debug('x_return_status from process_sales_order =' ||
                          x_return_status,
                          l_mod_name,
                          1);

                    IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                    THEN
                        Debug('process_sales_order failed', l_mod_name, 1);
                        RAISE CREATE_ORDER;
                    END IF;

                    UPDATE csd_product_transactions
                       SET prod_txn_status      = 'SUBMITTED',
                           interface_to_om_flag = 'Y'
                     WHERE product_transaction_id =
                           x_product_txn_rec.PRODUCT_TRANSACTION_ID;
                    IF SQL%NOTFOUND
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_ERR_PRD_TXN_UPDATE');
                        Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                              x_product_txn_rec.PRODUCT_TRANSACTION_ID);
                        Fnd_Msg_Pub.ADD;
                        RAISE CREATE_ORDER;
                    END IF;

                    UPDATE csd_repairs
                       SET ro_txn_status = 'OM_SUBMITTED'
                     WHERE repair_line_id =
                           x_product_txn_rec.REPAIR_LINE_ID;
                    IF SQL%NOTFOUND
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_ERR_REPAIRS_UPDATE');
                        Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                              x_product_txn_rec.repair_line_id);
                        Fnd_Msg_Pub.ADD;
                        RAISE CREATE_ORDER;
                    END IF;

                    -- swai: bug 6001057
                    -- rearranged code so that call to OM API can be used to update
                    -- project, unit number, or 3rd party end_customer
                    if (((x_product_txn_rec.project_id is not null)
                       OR (x_product_txn_rec.unit_number is not null)
                       OR (x_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')))
					   and (x_product_txn_rec.project_id <> FND_API.G_MISS_NUM)) then   --bug#6075825

                       OPEN order_line_cu(x_estimate_detail_id);
                       FETCH order_line_cu into l_order_line_id, l_p_ship_from_org_id;
                       CLOSE order_line_cu;

                       if (l_order_line_id) is not null then
                          l_Line_Tbl_Type(1)           := OE_Order_PUB.G_MISS_LINE_REC;
                          l_Line_Tbl_Type(1).line_id   := l_order_line_id;
                          l_Line_Tbl_Type(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                          -- taklam: update project and unit number fields
                          if ((x_product_txn_rec.project_id is not null) or (x_product_txn_rec.unit_number is not null)) then

                              l_Line_Tbl_Type(1).end_item_unit_number   := x_product_txn_rec.unit_number;

                              if (x_product_txn_rec.project_id is not null) then
                                 OPEN project_cu(x_product_txn_rec.project_id,l_p_ship_from_org_id);
                                 FETCH project_cu into l_project_count;
                                 CLOSE project_cu;

                                 if (l_project_count >= 1) then
                                    l_Line_Tbl_Type(1).project_id             := x_product_txn_rec.project_id;
                                    l_Line_Tbl_Type(1).task_id                := x_product_txn_rec.task_id;
                                 else
                                    FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PROJECT_UPDATE');
                                    FND_MESSAGE.SET_TOKEN('project_id',x_product_txn_rec.project_id);
                                    FND_MESSAGE.SET_TOKEN('ship_from_org_id',l_p_ship_from_org_id);
                                    FND_MSG_PUB.ADD;
                                    RAISE CREATE_ORDER;
                                 end if;
                              end if;
                          end if; -- end update project and unit number fields

                          -- swai: update 3rd party fields.
                          -- IB Owner must be set to END_CUSTOMER and end_custoemr_id mustbe
                          -- set to the SR customer account id in order for 3rd party lines to
                          -- avoid changing IB ownership during material transactions.
                          if (x_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')) then
                             -- get SR customer account
                             OPEN sr_account_cu (x_product_txn_rec.repair_line_id);
                             FETCH sr_account_cu into l_sr_account_id;
                             CLOSE sr_account_cu;
                             if (l_sr_account_id) is not null then
                                l_Line_Tbl_Type(1).ib_owner        := 'END_CUSTOMER';
                                l_Line_Tbl_Type(1).end_customer_id := l_sr_account_id;
                             end if;
                          end if; -- end update 3rd party fields

                          OE_ORDER_PUB.Process_Line(
                                   p_line_tbl        => l_Line_Tbl_Type,
                                   x_line_out_tbl    => x_Line_Tbl_Type,
                                   x_return_status   => x_return_status,
                                   x_msg_count       => x_msg_count,
                                   x_msg_data        => x_msg_data
                          );

                          IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                             FND_MESSAGE.SET_NAME('CSD','CSD_ERR_OM_PROCESS_LINE');
                             FND_MSG_PUB.ADD;
                             RAISE CREATE_ORDER;
                          END IF;
                       end if;  -- order line is not null
                    end if;
                    -- end swai: bug 6001057


                EXCEPTION
                    WHEN CREATE_ORDER THEN
                        Debug('In CREATE_ORDER exception', l_mod_name, 1);
                        RAISE CREATE_ORDER;
                    WHEN OTHERS THEN
                        Debug('In OTHERS exception', l_mod_name, 1);
                        RAISE CREATE_ORDER;
                END;
            END IF; -- end of create sales order

            -- Book the Sales Order if the book_sales_order_flag is checked
            IF x_product_txn_rec.book_sales_order_flag = 'Y'
            THEN

                BEGIN

                    -- Define Savepoint
                    SAVEPOINT book_sales_order;

                    Debug('x_estimate_detail_id =' || x_estimate_detail_id,
                          l_mod_name,
                          1);

                    BEGIN
                        -- Get the order header id from the charge line
                        SELECT a.order_header_id, a.order_line_id
                          INTO l_order_header_id, l_order_line_id
                          FROM cs_estimate_details a
                         WHERE a.estimate_detail_id = x_estimate_detail_id
                           AND a.order_header_id IS NOT NULL
                           AND a.order_line_id IS NOT NULL;

                        --assign the order header id
                        l_order_rec.order_header_id := l_order_header_id;
                        l_order_rec.order_line_id   := l_order_line_id;

                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            FND_MESSAGE.SET_NAME('CSD','CSD_API_BOOKING_FAILED'); /*FP Fixed for bug#5147030 message changed*/
                            /*
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_API_INV_EST_DETAIL_ID');
                            Fnd_Message.SET_TOKEN('ESTIMATE_DETAIL_ID',
                                                  x_estimate_detail_id);  */
                            Fnd_Msg_Pub.ADD;
                            Debug('Sales Order missing for estimate_detail_id =' ||
                                  x_estimate_detail_id,
                                  l_mod_name,
                                  1);
                            RAISE BOOK_ORDER;
                        WHEN TOO_MANY_ROWS THEN
                            Debug('Too many order header id',
                                  l_mod_name,
                                  1);
                            RAISE BOOK_ORDER;
                    END;

                    BEGIN
                        -- To Book an Order Sales Rep and ship_from_org_id is reqd
                        -- so check if the Order header has it
                        SELECT ship_from_org_id, unit_selling_price, org_id
                          INTO l_ship_from_org_id,
                               l_unit_selling_price,
                               l_order_rec.org_id
                          FROM oe_order_lines_all
                         WHERE line_id = l_order_line_id;
                           /*Fixed for bug#5368306
			                    OM does not require sales rep at line to book it.
			                    Depot should not check sales rep at line since oe
			                    allows to book an order without a sales rep at
			                    the line.
			                    Following condition which checks sales rep at
			                    order line has been commented.
			                  */
                          /* AND salesrep_id IS NOT NULL; */
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_API_SALES_REP_MISSING');
                            Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                                  l_order_line_id);
                            Fnd_Msg_Pub.ADD;
                            Debug('Sales rep missing for Line_id=' ||
                                  l_order_line_id,
                                  l_mod_name,
                                  1);
                            RAISE BOOK_ORDER;
                        WHEN TOO_MANY_ROWS THEN
                            Debug('Too many order ship_from_org_id',
                                  l_mod_name,
                                  1);
                    END;

                    IF l_ship_from_org_id IS NULL
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_API_SHIP_FROM_ORG_MISSING');
                        Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                              l_order_line_id);
                        Fnd_Msg_Pub.ADD;
                        Debug('Ship from Org Id missing for Line_id=' ||
                              l_order_line_id,
                              l_mod_name,
                              1);
                        RAISE BOOK_ORDER;
                    END IF;

                    IF l_unit_selling_price IS NULL
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_API_PRICE_MISSING');
                        Fnd_Message.SET_TOKEN('ORDER_LINE_ID',
                                              l_order_line_id);
                        Fnd_Msg_Pub.ADD;
                        Debug('Unit Selling price missing for Line_id=' ||
                              l_order_line_id,
                              l_mod_name,
                              1);
                        RAISE BOOK_ORDER;
                    END IF;

                    Debug('l_order_rec.order_header_id =' ||
                          l_order_rec.order_header_id,
                          l_mod_name,
                          1);

                    BEGIN
                        SELECT booked_flag
                          INTO l_booked_flag
                          FROM oe_order_headers_all
                         WHERE header_id = l_order_rec.order_header_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Debug('The Sales Order is booked OR does not exist',
                                  l_mod_name,
                                  1);
                            RAISE BOOK_ORDER;
                    END;

                    Debug('l_order_rec.org_id' || l_order_rec.org_id,
                          l_mod_name,
                          1);

                    IF NVL(l_booked_flag, 'N') = 'N'
                    THEN
                        -- swai: bug 6001057
                        -- rearranged code so that call to OM API can be used to update
                        -- project, unit number, or 3rd party end_customer
                        if (((x_product_txn_rec.project_id is not null)
                           OR (x_product_txn_rec.unit_number is not null)
                           OR (x_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')))
						   and (x_product_txn_rec.project_id <> FND_API.G_MISS_NUM)) then   --bug#6075825

                            if (l_order_line_id) is not null then
                                l_Line_Tbl_Type(1)           := OE_Order_PUB.G_MISS_LINE_REC;
                                l_Line_Tbl_Type(1).line_id   := l_order_line_id;
                                l_Line_Tbl_Type(1).operation := OE_GLOBALS.G_OPR_UPDATE;

                                -- taklam: update project and unit number fields
                                if ((x_product_txn_rec.project_id is not null) or (x_product_txn_rec.unit_number is not null)) then

                                  l_Line_Tbl_Type(1).end_item_unit_number   := x_product_txn_rec.unit_number;

                                  if (x_product_txn_rec.project_id is not null) then
                                     OPEN project_cu(x_product_txn_rec.project_id,l_ship_from_org_id);
                                     FETCH project_cu into l_project_count;
                                     CLOSE project_cu;

                                     if (l_project_count >= 1) then
                                        l_Line_Tbl_Type(1).project_id             := x_product_txn_rec.project_id;
                                        l_Line_Tbl_Type(1).task_id                := x_product_txn_rec.task_id;
                                     else
                                        FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PROJECT_UPDATE');
                                        FND_MESSAGE.SET_TOKEN('project_id',x_product_txn_rec.project_id);
                                        FND_MESSAGE.SET_TOKEN('ship_from_org_id',l_ship_from_org_id);
                                        FND_MSG_PUB.ADD;
                                        RAISE BOOK_ORDER;
                                     end if;
                                  end if;
                                end if;

                                -- swai: update 3rd party fields.
                                -- IB Owner must be set to END_CUSTOMER and end_custoemr_id mustbe
                                -- set to the SR customer account id in order for 3rd party lines to
                                -- avoid changing IB ownership during material transactions.
                                if (x_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')) then
                                 -- get SR customer account
                                 OPEN sr_account_cu (x_product_txn_rec.repair_line_id);
                                 FETCH sr_account_cu into l_sr_account_id;
                                 CLOSE sr_account_cu;
                                 if (l_sr_account_id) is not null then
                                    l_Line_Tbl_Type(1).ib_owner        := 'END_CUSTOMER';
                                    l_Line_Tbl_Type(1).end_customer_id := l_sr_account_id;
                                 end if;
                                end if; -- end update 3rd party fields

                                OE_ORDER_PUB.Process_Line(
                                      p_line_tbl        => l_Line_Tbl_Type,
                                      x_line_out_tbl    => x_Line_Tbl_Type,
                                      x_return_status   => x_return_status,
                                      x_msg_count       => x_msg_count,
                                      x_msg_data        => x_msg_data
                                );

                                IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                                    FND_MESSAGE.SET_NAME('CSD','CSD_ERR_OM_PROCESS_LINE');
                                    FND_MSG_PUB.ADD;
                                    RAISE BOOK_ORDER;
                                END IF;
                            end if;  -- order line is not null
                        end if;
                        -- end swai: bug 6001057

                        Debug('Call process_sales_order to book SO',
                              l_mod_name,
                              1);
                        PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                            p_commit           => Fnd_Api.g_false,
                                            p_init_msg_list    => Fnd_Api.g_true,
                                            p_validation_level => Fnd_Api.g_valid_level_full,
                                            p_action           => 'BOOK',
                                            p_order_rec        => l_order_rec,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data);

                        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                        THEN
                            Debug('process_sales_order failed to book Sales order',
                                  l_mod_name,
                                  1);
                            RAISE BOOK_ORDER;
                        END IF;
                    END IF;

                    --            -- Update product txn with the status
                    --            UPDATE csd_product_transactions
                    --            SET prod_txn_status = 'BOOKED',
                    --                book_sales_order_flag = 'Y'
                    --            WHERE product_transaction_id = x_product_txn_rec.PRODUCT_TRANSACTION_ID;
                    --            IF SQL%NOTFOUND then
                    --                FND_MESSAGE.SET_NAME('CSD','CSD_ERR_PRD_TXN_UPDATE');
                    --                FND_MESSAGE.SET_TOKEN('PRODUCT_TRANSACTION_ID',x_product_txn_rec.PRODUCT_TRANSACTION_ID);
                    --                FND_MSG_PUB.ADD;
                    --                RAISE BOOK_ORDER;
                    --            END IF;

                    --            Fix for bug#4020651
                    Csd_Update_Programs_Pvt.prod_txn_status_upd(p_repair_line_id => x_product_txn_rec.repair_line_id,
                                                                p_commit         => Fnd_Api.g_false);

                    --Update csd_repairs with status
                    UPDATE csd_repairs
                       SET ro_txn_status = 'OM_BOOKED'
                     WHERE repair_line_id =
                           x_product_txn_rec.REPAIR_LINE_ID;
                    IF SQL%NOTFOUND
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_ERR_REPAIRS_UPDATE');
                        Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                              x_product_txn_rec.repair_line_id);
                        Fnd_Msg_Pub.ADD;
                        RAISE BOOK_ORDER;
                    END IF;

                EXCEPTION
                    WHEN BOOK_ORDER THEN
                        Debug('In BOOK_ORDER Exception while booking SO',
                              l_mod_name,
                              1);
                        RAISE BOOK_ORDER;
                    WHEN OTHERS THEN
                        Debug('In OTHERS Exception while booking SO',
                              l_mod_name,
                              1);
                        RAISE BOOK_ORDER;
                END;
            END IF; --end of Book Sales Order

            -- Release Sales Order if the flag is checked
            IF x_product_txn_rec.release_sales_order_flag = 'Y'
            THEN
                BEGIN

                    -- Define savepoint
                    SAVEPOINT release_sales_order;

                    Debug('x_product_txn_rec.sub_inventory =' ||
                          x_product_txn_rec.sub_inventory,
                          l_mod_name,
                          1);

                    IF NVL(x_product_txn_rec.sub_inventory,
                           Fnd_Api.G_MISS_CHAR) <> Fnd_Api.G_MISS_CHAR
                    THEN
                        BEGIN
                            SELECT 'x'
                              INTO l_dummy
                              FROM mtl_secondary_inventories
                             WHERE secondary_inventory_name =
                                   x_product_txn_rec.sub_inventory
                               AND organization_id = l_ship_from_org_id;
                        EXCEPTION
                            WHEN NO_DATA_FOUND THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_API_SUB_INV_MISSING');
                                Fnd_Message.SET_TOKEN('SUB_INVENTORY',
                                                      x_product_txn_rec.sub_inventory);
                                Fnd_Msg_Pub.ADD;
                                Debug(x_product_txn_rec.sub_inventory ||
                                      ':Subinventory does not exist',
                                      l_mod_name,
                                      1);
                                RAISE RELEASE_ORDER;
                            WHEN OTHERS THEN
                                Debug('More than one Subinventory does exist with same name',
                                      l_mod_name,
                                      1);
                                RAISE RELEASE_ORDER;
                        END;
                        l_order_rec.PICK_FROM_SUBINVENTORY := x_product_txn_rec.sub_inventory;
                    END IF;
        /* R12 SN reservations change Begin */
        -- Get Item attributes in local variable
                   CSD_LOGISTICS_UTIL.Get_ItemAttributes(p_Inventory_Item_Id => x_Product_Txn_Rec.Inventory_Item_Id,
        		                        p_inv_org_id        => x_Product_Txn_Rec.inventory_org_id,
                           x_ItemAttributes    => l_ItemAttributes);
	              -- Get the default pick rule id
                   Fnd_Profile.Get('CSD_AUTO_SRL_RESERVE', l_auto_reserve_profile);
                   if(l_auto_reserve_profile is null) then
                       l_auto_reserve_profile := 'N';
                   end if;

				   Debug('Going to process reservation..', l_mod_name, 1);
				   Debug(l_auto_reserve_profile, l_mod_name,1);
				   Debug(x_Product_Txn_Rec.source_Serial_number, l_mod_name,1);
				   Debug(x_Product_Txn_Rec.sub_inventory, l_mod_name,1);
				   Debug(x_Product_Txn_Rec.action_type, l_mod_name,1);
				   Debug(to_char(l_itemAttributes.reservable_type), l_mod_name,1);
				   Debug(to_char(l_itemAttributes.serial_Code), l_mod_name,1);


                   -- swai: bug 5931926 - 12.0.2 added 3rd party action type
                   IF( l_auto_reserve_profile = 'Y'
                        AND x_Product_Txn_Rec.source_Serial_number is not null
                        AND x_Product_Txn_Rec.sub_inventory is not null
                        AND x_product_txn_rec.action_type IN ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY')
                        AND l_ItemAttributes.reservable_type = C_RESERVABLE
                        AND (l_ItemAttributes.serial_code = C_SERIAL_CONTROL_AT_RECEIPT
                              OR
                             l_ItemAttributes.serial_code = C_SERIAL_CONTROL_PREDEFINED) ) THEN

		             Debug('Checking reservation id for serial number..['
		                         ||x_Product_Txn_Rec.source_Serial_number||']', l_mod_name, 1);

		            l_serial_rsv_rec.inventory_item_id    := x_Product_Txn_Rec.inventory_item_id;
		            l_serial_rsv_rec.inv_organization_id  := x_Product_Txn_Rec.inventory_org_id;
		            l_serial_rsv_rec.order_header_id      := l_order_header_id;
		            l_serial_rsv_rec.order_line_id        := l_order_line_Id;
		            l_serial_rsv_rec.order_schedule_date  := sysdate;
		            l_serial_rsv_rec.serial_number        := x_Product_Txn_Rec.source_serial_number;
		            l_serial_rsv_rec.locator_id           := x_Product_Txn_Rec.locator_id;
		            l_serial_rsv_rec.revision             := x_Product_Txn_Rec.revision;
		            l_serial_rsv_rec.lot_number           := x_Product_Txn_Rec.lot_number;
		            l_serial_rsv_rec.subinventory_code    := x_Product_Txn_Rec.sub_inventory;
		            l_serial_rsv_rec.reservation_uom_code := x_Product_Txn_Rec.Unit_Of_Measure_Code;

		            Debug('Calling reserve serial..', l_mod_name, 1);
		            CSD_LOGISTICS_UTIL.Reserve_serial_number(l_serial_rsv_rec, x_return_status);

		            if(x_return_status = FND_API.G_RET_STS_ERROR) THEN
			            Fnd_Message.SET_NAME('CSD', 'CSD_SRL_RESERVE_FAILED');
			            Fnd_Msg_Pub.ADD;
			            RAISE RELEASE_ORDER;
		            END IF;

                 END IF;

        /* R12 SN reservations change End   */



                    -- R12 development changes
                    -- Added the code to get the picking rule from profile only if the product_txn_rec does
                    -- not have it.
                    IF (x_product_txn_rec.picking_rule_id IS NULL)
                    THEN
                        -- Get the default pick rule id
                        Fnd_Profile.Get('CSD_DEF_PICK_RELEASE_RULE',
                                        l_picking_rule_id);

                    ELSE

                        l_picking_rule_id := x_product_txn_rec.picking_rule_id;

                    END IF; -- End of if for input pick_rule_id check.

                    -- Get the Picking Rule Id
                    BEGIN
                        SELECT picking_rule_id
                          INTO l_picking_rule_id
                          FROM wsh_picking_rules
                         WHERE picking_rule_id = l_picking_rule_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_API_INV_PICKING_RULE_ID');
                            Fnd_Message.SET_TOKEN('PICKING_RULE_ID',
                                                  l_picking_rule_id);
                            Fnd_Msg_Pub.ADD;
                            Debug(l_picking_rule_id ||
                                  ':Picking Rule does not exist ',
                                  l_mod_name,
                                  1);
                            RAISE RELEASE_ORDER;
                        WHEN OTHERS THEN
                            Debug('More than one Picking Rule exist with same name',
                                  l_mod_name,
                                  1);
                            RAISE RELEASE_ORDER;
                    END;

                    l_order_rec.picking_rule_id := l_picking_rule_id;
                    l_order_rec.org_id          := l_ship_from_org_id;

                    BEGIN
                        SELECT released_status
                          INTO l_release_status
                          FROM wsh_delivery_details
                         WHERE source_line_id = l_order_line_id
			 AND    SOURCE_CODE = 'OE'; /*Fixed for bug#5846054 */
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Debug('No Delivery lines found', l_mod_name, 1);
                            RAISE RELEASE_ORDER;
                        WHEN TOO_MANY_ROWS THEN
                            Debug('Too Delivery lines found for the order line',
                                  l_mod_name,
                                  1);
                            RAISE RELEASE_ORDER;
                    END;

                    IF l_release_status IN ('R', 'B')
                    THEN
                        Debug('Call process_sales_order to pick release sales order',
                              l_mod_name,
                              1);
                        PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                            p_commit           => Fnd_Api.g_false,
                                            p_init_msg_list    => Fnd_Api.g_true,
                                            p_validation_level => Fnd_Api.g_valid_level_full,
                                            p_action           => 'PICK-RELEASE',
                                            p_order_rec        => l_order_rec,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data);

                        IF (x_return_status = Fnd_Api.G_RET_STS_ERROR)
                        THEN
                            Debug('process_sales_order failed',
                                  l_mod_name,
                                  1);
                            RAISE RELEASE_ORDER;
                        END IF;
                    END IF;

                    BEGIN
                        SELECT released_status
                          INTO l_release_status
                          FROM wsh_delivery_details
                         WHERE source_line_id = l_order_line_id
			 AND    SOURCE_CODE = 'OE'; /*Fixed for bug#5846054 */
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Debug('No Delivery lines found', l_mod_name, 1);
                            RAISE RELEASE_ORDER;
                        WHEN TOO_MANY_ROWS THEN
                            Debug('Too Delivery lines found for the order line',
                                  l_mod_name,
                                  1);
                            RAISE RELEASE_ORDER;
                    END;

                    IF l_release_status = 'Y'
                    THEN
                        -- swai: bug 5931926 - 12.0.2 added 3rd party action type
                        IF (x_product_txn_rec.ACTION_TYPE IN
                           ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))
                        THEN
                            UPDATE csd_product_transactions
                               SET prod_txn_status          = 'RELEASED',
                                   release_sales_order_flag = 'Y'
                             WHERE product_transaction_id =
                                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
                            IF SQL%NOTFOUND
                            THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_ERR_PRD_TXN_UPDATE');
                                Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                                      x_product_txn_rec.PRODUCT_TRANSACTION_ID);
                                Fnd_Msg_Pub.ADD;
                                RAISE RELEASE_ORDER;
                            END IF;
                        END IF;

                        UPDATE csd_repairs
                           SET ro_txn_status = 'OM_RELEASED'
                         WHERE repair_line_id =
                               x_product_txn_rec.REPAIR_LINE_ID;
                        IF SQL%NOTFOUND
                        THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_ERR_REPAIRS_UPDATE');
                            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                                  x_product_txn_rec.repair_line_id);
                            Fnd_Msg_Pub.ADD;
                            RAISE RELEASE_ORDER;
                        END IF;

                    ELSIF l_release_status IN ('S', 'B')
                    THEN
                        -- swai: bug 5931926 - 12.0.2 added 3rd party action type
                        IF (x_product_txn_rec.ACTION_TYPE IN
                           ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))
                        THEN
                            UPDATE csd_product_transactions
                               SET prod_txn_status = 'BOOKED'
                             WHERE product_transaction_id =
                                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
                            IF SQL%NOTFOUND
                            THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_ERR_PRD_TXN_UPDATE');
                                Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                                      x_product_txn_rec.PRODUCT_TRANSACTION_ID);
                                Fnd_Msg_Pub.ADD;
                                RAISE RELEASE_ORDER;
                            END IF;
                        END IF;

                        UPDATE csd_repairs
                           SET ro_txn_status = 'OM_BOOKED'
                         WHERE repair_line_id =
                               x_product_txn_rec.REPAIR_LINE_ID;
                        IF SQL%NOTFOUND
                        THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_ERR_REPAIRS_UPDATE');
                            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                                  x_product_txn_rec.repair_line_id);
                            Fnd_Msg_Pub.ADD;
                            RAISE RELEASE_ORDER;
                        END IF;

                    END IF;

                EXCEPTION
                    WHEN RELEASE_ORDER THEN
                        Debug('In RELEASE_ORDER Exception while releasing SO',
                              l_mod_name,
                              1);
                        RAISE RELEASE_ORDER;
                    WHEN OTHERS THEN
                        Debug('In OTHERS Exception while releasing SO',
                              l_mod_name,
                              1);
                        RAISE RELEASE_ORDER;
                END;
            END IF; -- end of Release Sales Order

            -- Ship the sales order if the flag is checked
            IF x_product_txn_rec.ship_sales_order_flag = 'Y'
            THEN

                BEGIN

                    -- Define savepoint
                    SAVEPOINT ship_sales_order;

                    BEGIN
                        SELECT requested_quantity, released_status
                          INTO l_ship_qty, l_release_status
                          FROM wsh_delivery_details
                         WHERE source_header_id =
                               l_order_rec.order_header_id
                           AND source_line_id = l_order_rec.order_line_id
			   AND SOURCE_CODE = 'OE'; /*Fixed for bug#5685341*/
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Debug('No Delivery Lines found', l_mod_name, 1);
                            RAISE SHIP_ORDER;
                        WHEN TOO_MANY_ROWS THEN
                            Debug('Many Delivery lines found',
                                  l_mod_name,
                                  1);
                            RAISE SHIP_ORDER;
                    END;

                    l_order_rec.shipped_quantity := l_ship_qty;
                    l_order_rec.serial_number    := x_product_txn_rec.source_serial_number;

                    IF l_release_status = 'Y'
                    THEN
                        Debug('Call process_sales_order to ship SO',
                              l_mod_name,
                              1);
                        PROCESS_SALES_ORDER(p_api_version      => 1.0,
                                            p_commit           => Fnd_Api.g_false,
                                            p_init_msg_list    => Fnd_Api.g_true,
                                            p_validation_level => Fnd_Api.g_valid_level_full,
                                            p_action           => 'SHIP',
                                            /*Fixed for bug#4433942 passing product
					      txn record as in parameter*/
                                            p_product_txn_rec  =>  x_product_txn_rec,
                                            p_order_rec        => l_order_rec,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data);

                        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
                        THEN
                            Debug('process_sales_order failed to ship sales order',
                                  l_mod_name,
                                  1);
                            RAISE SHIP_ORDER;
                        END IF;
                        -- swai: bug 5931926 - 12.0.2 added 3rd party action type
                        IF (x_product_txn_rec.ACTION_TYPE IN
                           ('SHIP', 'WALK_IN_ISSUE', 'SHIP_THIRD_PTY'))
                        THEN
                            UPDATE csd_product_transactions
                               SET prod_txn_status       = 'SHIPPED',
                                   ship_sales_order_flag = 'Y'
                             WHERE product_transaction_id =
                                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
                            IF SQL%NOTFOUND
                            THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_ERR_PRD_TXN_UPDATE');
                                Fnd_Message.SET_TOKEN('PRODUCT_TRANSACTION_ID',
                                                      x_product_txn_rec.PRODUCT_TRANSACTION_ID);
                                Fnd_Msg_Pub.ADD;
                                RAISE SHIP_ORDER;
                            END IF;
                        END IF;

                        UPDATE csd_repairs
                           SET ro_txn_status = 'OM_SHIPPED'
                         WHERE repair_line_id =
                               x_product_txn_rec.REPAIR_LINE_ID;
                        IF SQL%NOTFOUND
                        THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_ERR_REPAIRS_UPDATE');
                            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                                  x_product_txn_rec.repair_line_id);
                            Fnd_Msg_Pub.ADD;
                            RAISE SHIP_ORDER;
                        END IF;

                    END IF;

                EXCEPTION
                    WHEN SHIP_ORDER THEN
                        Debug('In SHIP_ORDER Exception', l_mod_name, 1);
                        RAISE SHIP_ORDER;
                    WHEN OTHERS THEN
                        Debug('In OTHERS Exception', l_mod_name, 1);
                        RAISE SHIP_ORDER;
                END;
            END IF; -- end of ship sales order

        END IF; --end of all process

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN CREATE_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO create_sales_order;
            -- update the prod txn as the charge
            -- line was not interfaced
            UPDATE csd_product_transactions
               SET interface_to_om_flag     = 'N',
                   book_sales_order_flag    = 'N',
                   release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            -- Update auto_process_rma if OM fails
            -- swai: bug 5931926 - 12.0.2 added 3rd party action type
            IF (x_product_txn_rec.action_type IN ('RMA', 'WALK_IN_RECEIPT', 'RMA_THIRD_PTY')) AND
               (x_product_txn_rec.action_code = 'CUST_PROD')
            THEN
                UPDATE csd_repairs
                   SET auto_process_rma = 'N'
                 WHERE repair_line_id = x_product_txn_rec.repair_line_id;
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN BOOK_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO book_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET book_sales_order_flag    = 'N',
                   release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            -- Update auto_process_rma if OM fails
            -- swai: bug 5931926 - 12.0.2 added 3rd party action type
            IF (x_product_txn_rec.action_type IN ('RMA', 'WALK_IN_RECEIPT', 'RMA_THIRD_PTY')) AND
               (x_product_txn_rec.action_code = 'CUST_PROD')
            THEN
                UPDATE csd_repairs
                   SET auto_process_rma = 'N'
                 WHERE repair_line_id = x_product_txn_rec.repair_line_id;
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN RELEASE_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO release_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN SHIP_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO ship_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET ship_sales_order_flag = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO create_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_product_txn;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_product_txn;

    /*-----------------------------------------------------------------*/
    /* Procedure Name: Create_ext_prod_txn                             */
    /* description : This procedure will create a product transaction  */
    /*               without creating charge line                      */
    /*-----------------------------------------------------------------*/
    PROCEDURE CREATE_EXT_PROD_TXN(p_api_version         IN NUMBER,
                                  p_commit              IN VARCHAR2,
                                  p_init_msg_list       IN VARCHAR2,
                                  p_validation_level    IN NUMBER,
                                  p_create_charge_lines IN VARCHAR2,
                                  x_product_txn_rec     IN OUT NOCOPY PRODUCT_TXN_REC,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_msg_count           OUT NOCOPY NUMBER,
                                  x_msg_data            OUT NOCOPY VARCHAR2

                                  ) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_EXT_PRODUCT_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(2000);
        l_msg_index              NUMBER;
        l_product_transaction_id NUMBER := NULL;
        l_serial_flag            BOOLEAN := FALSE;
        l_dummy                  VARCHAR2(1);
        l_check                  VARCHAR2(1);
        l_Charges_Rec            Cs_Charge_Details_Pub.Charges_Rec_type;
        l_estimate_Rec           Cs_Charge_Details_Pub.Charges_Rec_type;
        l_estimate_detail_id     NUMBER := NULL;
        x_estimate_detail_id     NUMBER := NULL;
        l_incident_id            NUMBER := NULL;
        l_order_rec              OM_INTERFACE_REC;
        l_reference_number       VARCHAR2(30) := '';
        l_contract_number        VARCHAR2(120) := '';
        l_bus_process_id         NUMBER := NULL;
        l_repair_type_ref        VARCHAR2(3) := '';
        l_line_type_id           NUMBER := NULL;
        l_txn_billing_type_id    NUMBER := NULL;
        l_party_id               NUMBER := NULL;
        l_account_id             NUMBER := NULL;
        l_order_header_id        NUMBER := NULL;
        l_release_status         VARCHAR2(10) := '';
        l_curr_code              VARCHAR2(10) := '';
        l_picking_rule_id        NUMBER := NULL;
        l_ship_qty               NUMBER := NULL;
        l_line_category_code     VARCHAR2(30) := '';
        l_ship_from_org_id       NUMBER := NULL;
        l_order_line_id          NUMBER := NULL;
        l_coverage_id            NUMBER := NULL;
        -- Bugfix 3617932, vkjain.
        -- Increasing the column length to 150
        -- l_coverage_name          VARCHAR2(150) := ''; -- Commented for bugfix 3617932
        l_txn_group_id       NUMBER := NULL;
        l_unit_selling_price NUMBER := NULL;

        create_order EXCEPTION;
        book_order EXCEPTION;
        release_order EXCEPTION;
        ship_order EXCEPTION;

        CURSOR get_account_details(p_incident_id IN NUMBER) IS
            SELECT customer_id, account_id
              FROM cs_incidents_all_b
             WHERE incident_id = p_incident_id;

        CURSOR estimate(p_rep_line_id IN NUMBER) IS
            SELECT estimate_detail_id, object_version_number
              FROM cs_estimate_details
             WHERE source_id = p_rep_line_id
               AND source_code = 'DR'
               AND interface_to_oe_flag = 'N'
               AND order_header_id IS NULL
               AND order_line_id IS NULL
               AND line_category_code = 'ORDER';

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_product_txn;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts

        -- Dump the API  in the log file
        Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                          p_api_name => l_api_name);

        -- Dump the IN parameters in the log file
        -- if the debug level > 5
        IF Fnd_Profile.value('CSD_DEBUG_LEVEL') > 5
        THEN
            Csd_Gen_Utility_Pvt.dump_prod_txn_rec(p_prod_txn_rec => x_product_txn_rec);
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('********* Check reqd parameter ***************');
            Csd_Gen_Utility_Pvt.ADD('Repair Line ID      =' ||
                                    x_product_txn_rec.repair_line_id);
            Csd_Gen_Utility_Pvt.ADD('Action Code         =' ||
                                    x_product_txn_rec.action_code);
            Csd_Gen_Utility_Pvt.ADD('Action Type         =' ||
                                    x_product_txn_rec.action_type);
            Csd_Gen_Utility_Pvt.ADD('Txn_billing_type_id =' ||
                                    x_product_txn_rec.txn_billing_type_id);
        END IF;

        -- Check the required parameter(txn_billing_type_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.txn_billing_type_id,
                                          p_param_name  => 'TXN_BILLING_TYPE_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(inventory_item_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.inventory_item_id,
                                          p_param_name  => 'INVENTORY_ITEM_ID',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(unit_of_measure_code)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.unit_of_measure_code,
                                          p_param_name  => 'UNIT_OF_MEASURE_CODE',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(quantity)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.quantity,
                                          p_param_name  => 'QUANTITY',
                                          p_api_name    => l_api_name);

        -- Check the required parameter(price_list_id)
        Csd_Process_Util.Check_Reqd_Param(p_param_value => x_product_txn_rec.price_list_id,
                                          p_param_name  => 'PRICE_LIST_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair line id');
        END IF;

        -- Validate the repair line ID if it exists in csd_repairs
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => x_product_txn_rec.repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate action type');
        END IF;

        -- Validate the Action Type if it exists in fnd_lookups
        IF NOT
            (Csd_Process_Util.Validate_action_type(p_action_type => x_product_txn_rec.action_type))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate action code');
        END IF;

        -- Validate the repair line ID if it exists in fnd_lookups
        IF NOT
            (Csd_Process_Util.Validate_action_code(p_action_code => x_product_txn_rec.action_code))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate product txn qty');
            Csd_Gen_Utility_Pvt.ADD('x_product_txn_rec.quantity =' ||
                                    x_product_txn_rec.quantity);
        END IF;

        -- Validate if the product txn quantity (customer product only)
        -- is not exceeding the repair order quantity
        -- swai: bug 5931926 - 12.0.2 do not validate quantity for third party lines
        -- since multiple parts can be shipped out.
        IF x_product_txn_rec.action_code = 'CUST_PROD' AND
           x_product_txn_rec.action_type not in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')
        THEN
            Csd_Process_Util.Validate_quantity(p_action_type    => x_product_txn_rec.action_type,
                                               p_repair_line_id => x_product_txn_rec.repair_line_id,
                                               p_prod_txn_qty   => x_product_txn_rec.quantity,
                                               x_return_status  => x_return_status);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Validate_Quantity failed ');
                END IF;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate product txn status');
            Csd_Gen_Utility_Pvt.ADD('x_product_txn_rec.PROD_TXN_STATUS =' ||
                                    x_product_txn_rec.PROD_TXN_STATUS);
        END IF;

        -- Validate the PROD_TXN_STATUS if it exists in fnd_lookups
        IF (x_product_txn_rec.PROD_TXN_STATUS IS NOT NULL) AND
           (x_product_txn_rec.PROD_TXN_STATUS <> Fnd_Api.G_MISS_CHAR)
        THEN
            BEGIN
                SELECT 'X'
                  INTO l_check
                  FROM fnd_lookups
                 WHERE lookup_type = 'CSD_PRODUCT_TXN_STATUS'
                   AND lookup_code = x_product_txn_rec.PROD_TXN_STATUS;
            EXCEPTION
                WHEN OTHERS THEN
                    Fnd_Message.SET_NAME('CSD', 'CSD_ERR_PROD_TXN_STATUS');
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;
        END IF;

        -- Get service request id from csd_repairs table
        -- using repair order
        BEGIN
            SELECT incident_id
              INTO l_incident_id
              FROM csd_repairs
             WHERE repair_line_id = x_product_txn_rec.repair_line_id;
        EXCEPTION
            WHEN OTHERS THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                      x_product_txn_rec.repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_incident_id    =' || l_incident_id);
        END IF;

        -- Get the business process id
        -- Forward port bug fix# 2756313
        --l_bus_process_id := CSD_PROCESS_UTIL.GET_BUS_PROCESS(l_incident_id);

        l_bus_process_id := Csd_Process_Util.GET_BUS_PROCESS(x_product_txn_rec.repair_line_id);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_bus_process_id =' ||
                                    l_bus_process_id);
        END IF;

        IF l_bus_process_id < 0
        THEN
            IF NVL(x_product_txn_rec.business_process_id,
                   Fnd_Api.G_MISS_NUM) <> Fnd_Api.G_MISS_NUM
            THEN
                l_bus_process_id := x_product_txn_rec.business_process_id;
            ELSE
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Business process Id does not exist ');
                END IF;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Getting the Coverage and txn Group Id');
            Csd_Gen_Utility_Pvt.ADD('contract_line_id =' ||
                                    x_product_txn_rec.contract_id);
        END IF;

        IF l_incident_id IS NOT NULL
        THEN
            OPEN get_account_details(l_incident_id);
            FETCH get_account_details
                INTO l_party_id, l_account_id;
            IF (get_account_details%NOTFOUND OR l_party_id IS NULL)
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_PARTY_MISSING');
                Fnd_Message.SET_TOKEN('INCIDENT_ID', l_incident_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            IF get_account_details%ISOPEN
            THEN
                CLOSE get_account_details;
            END IF;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_party_id                            =' ||
                                    l_party_id);
            Csd_Gen_Utility_Pvt.ADD('l_account_id                          =' ||
                                    l_account_id);
            Csd_Gen_Utility_Pvt.ADD('x_product_txn_rec.txn_billing_type_id =' ||
                                    x_product_txn_rec.txn_billing_type_id);
            Csd_Gen_Utility_Pvt.ADD('x_product_txn_rec.organization_id     =' ||
                                    x_product_txn_rec.organization_id);
        END IF;

        -- Derive the line type and line category code
        -- from the transaction billing type
        Csd_Process_Util.GET_LINE_TYPE(p_txn_billing_type_id => x_product_txn_rec.txn_billing_type_id,
                                       p_org_id              => x_product_txn_rec.organization_id,
                                       x_line_type_id        => l_line_type_id,
                                       x_line_category_code  => l_line_category_code,
                                       x_return_status       => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_line_type_id                  =' ||
                                    l_line_type_id);
            Csd_Gen_Utility_Pvt.ADD('l_line_category_code            =' ||
                                    l_line_category_code);
            Csd_Gen_Utility_Pvt.ADD('x_product_txn_rec.price_list_id =' ||
                                    x_product_txn_rec.price_list_id);
        END IF;

        -- If line_type_id Or line_category_code is null
        -- then raise error
        IF (l_line_type_id IS NULL OR l_line_category_code IS NULL)
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_LINE_TYPE_MISSING');
            Fnd_Message.SET_TOKEN('TXN_BILLING_TYPE_ID',
                                  x_product_txn_rec.txn_billing_type_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Get the currency code from the price list if it is null or g_miss
        IF NVL(x_product_txn_rec.price_list_id, Fnd_Api.G_MISS_NUM) <>
           Fnd_Api.G_MISS_NUM
        THEN
            BEGIN
                SELECT currency_code
                  INTO l_curr_code
                  FROM oe_price_lists
                 WHERE price_list_id = x_product_txn_rec.price_list_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_API_INV_PRICE_LIST_ID');
                    Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                          x_product_txn_rec.price_list_id);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                WHEN TOO_MANY_ROWS THEN
                    IF (g_debug > 0)
                    THEN
                        Csd_Gen_Utility_Pvt.ADD('Too many currency_codes');
                    END IF;
            END;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_curr_code          =' ||
                                    l_curr_code);
        END IF;

        -- If l_curr_code is null then raise error
        IF l_curr_code IS NULL
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_CURR_CODE');
            Fnd_Message.SET_TOKEN('PRICE_LIST_ID',
                                  x_product_txn_rec.price_list_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        l_serial_flag := Csd_Process_Util.Is_item_serialized(x_product_txn_rec.inventory_item_id);


        -- swai: bug 5931926 - 12.0.2 3rd party logistics
        -- Instead of adding 3rd party action types to if-then statement,
        -- we are commenting the code out altogether.  Currently, the
        -- if conditions do not allow any product transaction lines
        -- through except walk-in-receipt, which is no longer supported.
        -- We should allow RMA line creation without Serial number for
        -- all action types.
        /*****
        -- Serial Number required if the item is serialized
        -- changing it from serial_number to source_serial_number 11.5.10
        IF l_serial_flag AND x_product_txn_rec.source_serial_number IS NULL AND
           x_product_txn_rec.action_type NOT IN ('SHIP') AND
           (x_product_txn_rec.action_code <> 'LOANER' AND
           x_product_txn_rec.action_type <>'RMA')
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_SERIAL_NUM_MISSING');
            Fnd_Message.SET_TOKEN('INVENTORY_ITEM_ID',
                                  x_product_txn_rec.inventory_item_id);
            Fnd_Msg_Pub.ADD;
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Serial Number missing for inventory_item_id =' ||
                                        x_product_txn_rec.inventory_item_id);
            END IF;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;
        *****/

        -- assigning values for the charge record
        x_product_txn_rec.incident_id         := l_incident_id;
        x_product_txn_rec.business_process_id := l_bus_process_id;
        x_product_txn_rec.line_type_id        := l_line_type_id;
        x_product_txn_rec.currency_code       := l_curr_code;
        x_product_txn_rec.line_category_code  := l_line_category_code;
        x_estimate_detail_id                  := x_product_txn_rec.estimate_detail_id;

        Csd_Gen_Utility_Pvt.ADD('Call csd_product_transactions_pkg.insert_row to insert prod txns');

        Csd_Product_Transactions_Pkg.INSERT_ROW(px_PRODUCT_TRANSACTION_ID  => x_product_txn_rec.PRODUCT_TRANSACTION_ID,
                                                p_REPAIR_LINE_ID           => x_product_txn_rec.REPAIR_LINE_ID,
                                                p_ESTIMATE_DETAIL_ID       => x_estimate_detail_id,
                                                p_ACTION_TYPE              => x_product_txn_rec.ACTION_TYPE,
                                                p_ACTION_CODE              => x_product_txn_rec.ACTION_CODE,
                                                p_LOT_NUMBER               => x_product_txn_rec.LOT_NUMBER,
                                                p_SUB_INVENTORY            => x_product_txn_rec.SUB_INVENTORY,
                                                p_INTERFACE_TO_OM_FLAG     => x_product_txn_rec.INTERFACE_TO_OM_FLAG,
                                                p_BOOK_SALES_ORDER_FLAG    => x_product_txn_rec.BOOK_SALES_ORDER_FLAG,
                                                p_RELEASE_SALES_ORDER_FLAG => x_product_txn_rec.RELEASE_SALES_ORDER_FLAG,
                                                p_SHIP_SALES_ORDER_FLAG    => x_product_txn_rec.SHIP_SALES_ORDER_FLAG,
                                                p_PROD_TXN_STATUS          => 'SUBMITTED',
                                                p_PROD_TXN_CODE            => x_product_txn_rec.PROD_TXN_CODE,
                                                p_LAST_UPDATE_DATE         => SYSDATE,
                                                p_CREATION_DATE            => SYSDATE,
                                                p_LAST_UPDATED_BY          => Fnd_Global.USER_ID,
                                                p_CREATED_BY               => Fnd_Global.USER_ID,
                                                p_LAST_UPDATE_LOGIN        => Fnd_Global.USER_ID,
                                                p_ATTRIBUTE1               => x_product_txn_rec.ATTRIBUTE1,
                                                p_ATTRIBUTE2               => x_product_txn_rec.ATTRIBUTE2,
                                                p_ATTRIBUTE3               => x_product_txn_rec.ATTRIBUTE3,
                                                p_ATTRIBUTE4               => x_product_txn_rec.ATTRIBUTE4,
                                                p_ATTRIBUTE5               => x_product_txn_rec.ATTRIBUTE5,
                                                p_ATTRIBUTE6               => x_product_txn_rec.ATTRIBUTE6,
                                                p_ATTRIBUTE7               => x_product_txn_rec.ATTRIBUTE7,
                                                p_ATTRIBUTE8               => x_product_txn_rec.ATTRIBUTE8,
                                                p_ATTRIBUTE9               => x_product_txn_rec.ATTRIBUTE9,
                                                p_ATTRIBUTE10              => x_product_txn_rec.ATTRIBUTE10,
                                                p_ATTRIBUTE11              => x_product_txn_rec.ATTRIBUTE11,
                                                p_ATTRIBUTE12              => x_product_txn_rec.ATTRIBUTE12,
                                                p_ATTRIBUTE13              => x_product_txn_rec.ATTRIBUTE13,
                                                p_ATTRIBUTE14              => x_product_txn_rec.ATTRIBUTE14,
                                                p_ATTRIBUTE15              => x_product_txn_rec.ATTRIBUTE15,
                                                p_CONTEXT                  => x_product_txn_rec.CONTEXT,
                                                p_OBJECT_VERSION_NUMBER    => 1,
                                                P_SOURCE_SERIAL_NUMBER     => x_product_txn_rec.source_serial_number,
                                                P_SOURCE_INSTANCE_ID       => x_product_txn_rec.source_instance_Id,
                                                P_NON_SOURCE_SERIAL_NUMBER => x_product_txn_rec.non_source_serial_number,
                                                P_NON_SOURCE_INSTANCE_ID   => x_product_txn_rec.non_source_instance_id,
                                                P_REQ_HEADER_ID            => x_product_txn_rec.Req_Header_Id,
                                                P_REQ_LINE_ID              => x_product_txn_rec.Req_Line_Id,
                                                P_ORDER_HEADER_ID          => x_Product_Txn_Rec.Order_Header_Id,
                                                P_ORDER_LINE_ID            => x_Product_Txn_Rec.Order_Line_Id,
                                                P_PRD_TXN_QTY_RECEIVED     => x_product_txn_rec.Prd_Txn_Qty_Received,
                                                P_PRD_TXN_QTY_SHIPPED      => x_product_txn_rec.Prd_Txn_Qty_Shipped,
                                                P_SUB_INVENTORY_RCVD       => x_product_txn_rec.Sub_Inventory_Rcvd,
                                                P_LOT_NUMBER_RCVD          => x_product_txn_rec.Lot_Number_Rcvd,
                                                P_LOCATOR_ID               => x_product_txn_rec.Locator_Id,
                                                p_picking_rule_id          => x_product_txn_rec.picking_rule_id, --R12 development changes
                                                P_PROJECT_ID               => x_product_txn_rec.project_id,
                                                P_TASK_ID                  => x_product_txn_rec.task_id,
                                                P_UNIT_NUMBER              => x_product_txn_rec.unit_number,
                                                P_INTERNAL_PO_HEADER_ID    => x_product_txn_rec.internal_po_header_id);  -- swai: bug 6148019


        Csd_Gen_Utility_Pvt.ADD('PRODUCT_TRANSACTION_ID    =' ||
                                x_product_txn_rec.PRODUCT_TRANSACTION_ID);
        Csd_Gen_Utility_Pvt.ADD('REPAIR_ORDER_ID    =' ||
                                x_product_txn_rec.repair_line_id);

        UPDATE csd_repairs
           SET ro_txn_status = 'OM_SUBMITTED'
         WHERE repair_line_id = x_product_txn_rec.REPAIR_LINE_ID;
        IF SQL%NOTFOUND
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_ERR_REPAIRS_UPDATE');
            Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                  x_product_txn_rec.repair_line_id);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO create_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_product_txn;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_ext_prod_txn;

    /*----------------------------------------------------------------*/
    /* procedure name: update_product_txn                             */
    /* description   : procedure to update product txn lines.It is    */
    /*                 called from ON-UPDATE trigger in the repair    */
    /*                 order form                                     */
    /*----------------------------------------------------------------*/

    PROCEDURE update_product_txn(p_api_version      IN NUMBER,
                                 p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                 p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                 p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                 x_product_txn_rec  IN OUT NOCOPY PRODUCT_TXN_REC,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_PRODUCT_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
      	l_return_status      VARCHAR2(1);
        l_estimate_Rec       Cs_Charge_Details_Pub.charges_rec_type;
        l_prodtxn_db_attr    Csd_Logistics_Util.PRODTXN_DB_ATTR_REC;
        l_order_Rec          Csd_Process_Pvt.om_interface_rec;
        l_est_detail_id      NUMBER;
		    l_add_to_order_id    NUMBER;
		    l_add_to_order_flag  VARCHAR2(1);
	    	l_transaction_type_id  NUMBER;
	    	l_repair_line_id     NUMBER;
        l_order_header_id    NUMBER; --bug 7355526
        l_ship_from_org_id   NUMBER; --bug 7355526

	      create_order EXCEPTION;
        book_order EXCEPTION;
        release_order EXCEPTION;
        ship_order EXCEPTION;


        CURSOR estimate(p_rep_line_id IN NUMBER) IS
            SELECT estimate_detail_id, object_version_number
            FROM cs_estimate_details
            WHERE source_id = p_rep_line_id
               AND source_code = 'DR'
               AND interface_to_oe_flag = 'N'
               AND order_header_id IS NULL
               AND order_line_id IS NULL;


        -- Variables used in FND Log
        l_error_level NUMBER := Fnd_Log.LEVEL_ERROR;
        l_excep_level NUMBER := Fnd_Log.LEVEL_EXCEPTION;
        l_statement_level  NUMBER := Fnd_Log.LEVEL_STATEMENT;

        l_mod_name    VARCHAR2(2000) := 'csd.plsql.csd_process_pvt.update_product_txn';

    BEGIN


        SAVEPOINT UPDATE_PRODUCT_TXN_PVT;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Fix for bug#6210765
        -- Initialize message list if p_init_msg_list is set to TRUE.
	IF Fnd_Api.to_Boolean(p_init_msg_list)
	THEN
	  Fnd_Msg_Pub.initialize;
	END IF;


        l_prodtxn_db_attr := Csd_Logistics_Util.get_prodtxn_db_attr(x_product_txn_rec.product_transaction_id);

        -----------------------------------------------------------------------------
        /*********************************************************************
        /* Code here got moved to CSD_LOGISTICS_UTIL.upd_prodtxn_n_chrgline
        **********************************************************************/
        -----------------------------------------------------------------------------
        Csd_Logistics_Util.upd_prodtxn_n_chrgline(x_product_txn_rec ,
				                  l_prodtxn_db_attr,
				                  l_est_detail_id,
						  l_repair_line_id,
						  l_add_to_order_flag,
						  l_add_to_order_id,
						  l_transaction_type_id);

	x_product_txn_Rec.estimate_detail_id  := l_est_detail_id;
	x_product_txn_Rec.repair_line_id      := l_repair_line_id;
	x_product_txn_Rec.add_to_order_flag   := l_add_to_order_flag;
	x_product_txn_Rec.order_header_id     := l_add_to_order_id;
        x_product_txn_rec.transaction_type_id := l_transaction_type_id;

        Debug('process_txn_flag      =' ||
              x_product_txn_rec.process_txn_flag,
              l_mod_name,
              l_statement_level);
        Debug('interface_to_om_flag  =' ||
              x_product_txn_rec.interface_to_om_flag,
              l_mod_name,
              l_statement_level);
        Debug('book_sales_order_flag =' ||
              x_product_txn_rec.book_sales_order_flag,
              l_mod_name,
              l_statement_level);
        Debug('release_sales_order_flag =' ||
              x_product_txn_rec.release_sales_order_flag,
              l_mod_name,
              l_statement_level);
        Debug('ship_sales_order_flag =' ||
              x_product_txn_rec.ship_sales_order_flag,
              l_mod_name,
              l_statement_level);


        IF x_product_txn_rec.process_txn_flag = 'Y'
        THEN

             -- Define savepoint
             SAVEPOINT create_sales_order;

        /*******************************************************************
        Code here has been moved to CSD_LOGISTICS_UTIL.interface_prodtxn
        ********************************************************************/

		  l_order_Rec := Csd_Logistics_Util.get_order_rec(x_product_txn_rec.repair_line_id);

		  --bug#6071005
		  if (x_product_txn_rec.order_line_id is not null) THEN
		      l_order_Rec.order_line_id := x_product_txn_rec.order_line_id;
		  End If;

        -- swai: bug 5931926 - 12.0.2 3rd party logistics.  If the bill to party
        -- and account have been specified, then this is a 3rd party logistics line,
        -- and we need to override the SR party and account from get_order_rec with
        -- the thrid party info
        /*IF (nvl(x_product_txn_rec.bill_to_account_id, FND_API.GMISS_NUM) <> FND_API.GMISS_NUM) AND
           (nvl(x_product_txn_rec.bill_to_party_id, FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) THEN          */
        -- nnadig: bug 9187830 - ensure bill-to info is only set for  3rd party lines
        IF (x_product_txn_rec.action_type in ('RMA_THIRD_PTY', 'SHIP_THIRD_PTY')) and
           (x_product_txn_rec.bill_to_party_id is not null) and
           (x_product_txn_rec.bill_to_account_id is not null) THEN
           l_order_Rec.party_id := x_product_txn_rec.bill_to_party_id;
           l_order_Rec.account_id := x_product_txn_rec.bill_to_account_id;
        END IF;

            Csd_Logistics_Util.interface_prodtxn(  x_return_status  =>   l_return_status,
		                                         p_product_txn_rec => x_product_txn_rec,
                        						 p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        						 px_order_rec          => l_order_rec);

		  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
		      RAISE Create_ORDER;
		  END IF;
            IF l_prodtxn_db_attr.curr_book_order_flag <>
               x_product_txn_rec.book_sales_order_flag AND
               x_product_txn_rec.book_sales_order_flag = 'Y'
            THEN
                -- Define savepoint
                SAVEPOINT book_sales_order;
                /***************************************************
                Code here has been moved to the api book_prodtxn
                ****************************************************/
                Csd_Logistics_Util.book_prodtxn(  x_return_status  =>   l_return_status,
			                                   p_product_txn_rec => x_product_txn_rec,
                        						 p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        						 px_order_rec          => l_order_rec);
			  IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				 RAISE BOOK_ORDER;
			  END IF;


            END IF; -- end of book order

            IF l_prodtxn_db_attr.curr_release_order_flag <>
               x_product_txn_rec.release_sales_order_flag AND
               x_product_txn_rec.release_sales_order_flag = 'Y'
            THEN
                    -- Define savepoint
                    SAVEPOINT release_sales_order;


		            -- begin bug fix #7355526, nnadig
                -- FP for bug fix#9198116: validate the subinventory information
                Begin
                  Select ship_from_org_id, header_id
                  into l_ship_from_org_id, l_order_header_id
                  from oe_order_lines_all oel,
                  cs_estimate_details ced
                  where oel.line_id = ced.order_line_id
                  and  ced.estimate_detail_id = x_product_txn_rec.estimate_detail_id;
                Exception
                When no_data_found then
                  Debug('Order Line not found ',l_mod_name,1);
                RAISE RELEASE_ORDER;
                End;

                -- If wrong sub-inventory is entered, throw explanatory error message
                if x_product_txn_rec.sub_inventory is not null then
                  if NOT csd_process_util.validate_subinventory_ship(
                  --p_org_id  => cs_std.get_item_valdn_orgzn_id, -- FP for bug fix 9198116
                  p_org_id  => l_ship_from_org_id,
                  p_sub_inv => x_product_txn_rec.sub_inventory,
                  p_inventory_item_id => x_product_txn_rec.inventory_item_id,
                  p_serial_number => x_product_txn_rec.source_serial_number  ) then
                    fnd_message.set_name('CSD','CSD_NEG_INV_IN_SHIP');
                    fnd_message.set_token('SUBINV',x_product_txn_rec.sub_inventory);
                    fnd_msg_pub.add;
                    RAISE RELEASE_ORDER;
                  end if;
                end if;

               -- validate if the line/header is on hold. If so, throw explanatory error message
                if CSD_PROCESS_UTIL.validate_order_for_holds
                            (   p_action_type     => 'SHIP',
                                p_order_header_id => l_order_header_id,
                                p_order_line_id   => x_product_txn_rec.order_line_id ) then
                      fnd_message.set_name('CSD','CSD_OM_ORDER_ON_HOLD');
                      fnd_message.set_token('ACTION','Shipping');
                      fnd_message.set_token('ORDER_NUM',x_product_txn_rec.order_number);
                      fnd_msg_pub.add;
                      RAISE RELEASE_ORDER;
                end if;
                -- end bug fix #7355526, nnadig
                    /*******************************************************************
                    Code here has been moved to CSD_LOGISTICS_UTIL.pickrelease_prodtxn
                    ********************************************************************/
                    Csd_Logistics_Util.pickrelease_prodtxn(x_return_status  =>   l_return_status,
				                 p_product_txn_rec => x_product_txn_rec,
                        			  p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        			  px_order_rec          => l_order_rec);
				IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				  RAISE RELEASE_ORDER;
			     END IF;
            END IF; --end of pick-release sales order

            IF l_prodtxn_db_attr.curr_ship_order_flag <>
               x_product_txn_rec.ship_sales_order_flag AND
               x_product_txn_rec.ship_sales_order_flag = 'Y'
            THEN
                    -- Define savepoint
                    SAVEPOINT ship_sales_order;
                    /*******************************************************************
                    Code here has been moved to CSD_LOGISTICS_UTIL.ship_prodtxn
                    ********************************************************************/
                    Csd_Logistics_Util.ship_prodtxn( x_return_status  =>   l_return_status,
				           p_product_txn_rec => x_product_txn_rec,
                        		 p_prodtxn_db_attr     => l_prodtxn_db_attr,
                        		 px_order_rec          => l_order_rec);

				IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
				   RAISE SHIP_ORDER;
				END IF;

            END IF; -- end of ship sales order

        END IF; --end of process txn

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN CREATE_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

		       /*FP Fixed for bug#4526773
		         When error occurred then complete rollback should be
		         done so that sanity of charge line and product line
		         remain intact.
		       */
            --ROLLBACK TO create_sales_order;

      		 ROLLBACK TO UPDATE_PRODUCT_TXN_PVT;

            -- update the prod txn as the charge
            -- line was not interfaced
            UPDATE csd_product_transactions
               SET interface_to_om_flag     = 'N',
                   book_sales_order_flag    = 'N',
                   release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN BOOK_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO book_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET book_sales_order_flag    = 'N',
                   release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN RELEASE_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO release_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET release_sales_order_flag = 'N',
                   ship_sales_order_flag    = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN SHIP_ORDER THEN
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            ROLLBACK TO ship_sales_order;
            -- update the prod txn as the order
            -- line was not booked
            UPDATE csd_product_transactions
               SET ship_sales_order_flag = 'N'
             WHERE product_transaction_id =
                   x_product_txn_rec.PRODUCT_TRANSACTION_ID;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO UPDATE_PRODUCT_TXN_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
             Debug('in exc_error, x_msg_data,count[' || x_msg_data|| ','||to_char(x_msg_count)||']',
			    l_mod_name,
			    l_statement_level);
		   IF x_msg_count > 1 THEN
			  FOR i IN 1..x_msg_count LOOP
				l_msg_data := apps.FND_MSG_PUB.Get(i,FND_API.G_TRUE) ;
				Debug('in exc_error, l_msg_data[' || l_msg_data||']',
					    l_mod_name,
					    l_statement_level);
			  END LOOP ;
		   END IF ;
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_PRODUCT_TXN_PVT;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
             Debug('in unexp_Error, x_msg_data[' || x_msg_data||']',
              l_mod_name,
              l_statement_level);
		   IF x_msg_count > 1 THEN
			  FOR i IN 1..x_msg_count LOOP
				l_msg_data := apps.FND_MSG_PUB.Get(i,apps.FND_API.G_FALSE) ;
				Debug('in exc_error, l_msg_data[' || l_msg_data||']',
					    l_mod_name,
					    l_statement_level);
			  END LOOP ;
		   END IF ;
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO UPDATE_PRODUCT_TXN_PVT;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
             Debug('in others, x_msg_data[' || x_msg_data||']',
              l_mod_name,
              l_statement_level);
		   IF x_msg_count > 1 THEN
			  FOR i IN 1..x_msg_count LOOP
				l_msg_data := apps.FND_MSG_PUB.Get(i,apps.FND_API.G_FALSE) ;
				Debug('in exc_error, l_msg_data[' || l_msg_data||']',
					    l_mod_name,
					    l_statement_level);
			  END LOOP ;
		   END IF ;
    END update_product_txn;

    /*--------------------------------------------------*/
    /* procedure name: delete_product_txn               */
    /* description   : procedure used to delete         */
    /*                 product transaction lines        */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE delete_product_txn(p_api_version      IN NUMBER,
                                 p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                 p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                 p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                 p_product_txn_id   IN NUMBER,
                                 x_return_status    OUT NOCOPY VARCHAR2,
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'DELETE_PRODUCT_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
        l_Charges_Rec        Cs_Charge_Details_Pub.charges_rec_type;
        x_estimate_detail_id NUMBER;
        l_est_detail_id      NUMBER;
        l_delete_allow       VARCHAR2(1);

    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT delete_product_txn;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check reqd parameter :prod txn Id ');
            Csd_Gen_Utility_Pvt.ADD('product txn Id  = ' ||
                                    p_product_txn_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_product_txn_id,
                                          p_param_name  => 'PRODUCT_TRANSACTION_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate product txn id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_prod_txn_id(p_prod_txn_id => p_product_txn_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        -- The Product txn line is allowed to delete
        -- only if it is not interfaced
        BEGIN
            SELECT a.estimate_detail_id
              INTO l_est_detail_id
              FROM csd_product_transactions a, cs_estimate_details b
             WHERE a.estimate_detail_id = b.estimate_detail_id
               AND a.product_transaction_id = p_product_txn_id
               AND b.order_header_id IS NULL;

            l_delete_allow := 'Y';
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                l_delete_allow := 'N';
                Fnd_Message.SET_NAME('CSD', 'CSD_API_DELETE_NOT_ALLOWED');
                --FND_MESSAGE.SET_TOKEN('PRODUCT_TXN_ID',p_product_txn_id);
                Fnd_Msg_Pub.ADD;
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Product txn is interfaced,so it cannot be deleted');
                END IF;
                RAISE Fnd_Api.G_EXC_ERROR;
            WHEN TOO_MANY_ROWS THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Too many from Product txn line is allowed to delete');
                END IF;
        END;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('l_delete_allow     =' ||
                                    l_delete_allow);
            Csd_Gen_Utility_Pvt.ADD('Estimate Detail Id =' ||
                                    l_est_detail_id);
        END IF;

        IF l_delete_allow = 'Y'
        THEN
            l_Charges_Rec.estimate_detail_id := l_est_detail_id;
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call process_charge_lines to delete');
            END IF;

            PROCESS_CHARGE_LINES(p_api_version        => 1.0,
                                 p_commit             => Fnd_Api.g_false,
                                 p_init_msg_list      => Fnd_Api.g_true,
                                 p_validation_level   => Fnd_Api.g_valid_level_full,
                                 p_action             => 'DELETE',
                                 p_Charges_Rec        => l_Charges_Rec,
                                 x_estimate_detail_id => x_estimate_detail_id,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data);

            IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
            THEN
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Call csd_product_transactions_pkg.Delete_Row');
            END IF;

            Csd_Product_Transactions_Pkg.Delete_Row(p_PRODUCT_TRANSACTION_ID => p_product_txn_id);
        END IF; --end of delete

        -- Api body ends here

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            ROLLBACK TO delete_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_product_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO delete_product_txn;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END delete_product_txn;

    /*--------------------------------------------------*/
    /* procedure name: create_default_prod_txn          */
    /* description   : procedure used to create         */
    /*         default product transaction lines        */
    /*                                                  */
    /*--------------------------------------------------*/

    PROCEDURE create_default_prod_txn(p_api_version				IN	NUMBER,
                                      p_commit					IN	VARCHAR2 := Fnd_Api.g_false,
                                      p_init_msg_list			IN	VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level		IN	NUMBER := Fnd_Api.g_valid_level_full,
                                      p_repair_line_id			IN	NUMBER,
									  p_create_thirdpty_line	IN	VARCHAR2  := Fnd_Api.g_false,
                                      x_return_status			OUT NOCOPY VARCHAR2,
                                      x_msg_count				OUT NOCOPY NUMBER,
                                      x_msg_data				OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_DEFAULT_PROD_TXN';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count       NUMBER;
        l_msg_data        VARCHAR2(2000);
        l_msg_index       NUMBER;
        l_product_txn_rec product_txn_rec;
        x_prod_txn_tbl    product_txn_tbl;
        x_msg_index_out   NUMBER;
        l_msg_text        VARCHAR2(2000) := '';

        l_sr_add_to_order_flag  VARCHAR2(10);
        l_ro_add_to_order_flag  VARCHAR2(10);
        l_add_rma_to_id       NUMBER;
        l_add_ship_to_id      NUMBER;


    BEGIN
        -- Standard Start of API savepoint
        SAVEPOINT create_default_prod_txn;

		--
		-- MOAC initialization
		--
		MO_GLOBAL.init('CS_CHARGES');

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Check the required parameter:(repair_line_id)');
            Csd_Gen_Utility_Pvt.ADD('Repair line id =' || p_repair_line_id);
        END IF;

        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_repair_line_id,
                                          p_param_name  => 'REPAIR_LINE_ID',
                                          p_api_name    => l_api_name);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Validate repair line id');
        END IF;

        -- Validate the repair line ID
        IF NOT
            (Csd_Process_Util.Validate_rep_line_id(p_repair_line_id => p_repair_line_id))
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Build the product txn table');
        END IF;

        l_sr_add_to_order_flag := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_SR');
        l_sr_add_to_order_flag := nvl(l_sr_Add_to_order_flag, 'N');

        l_ro_add_to_order_flag := fnd_profile.value('CSD_ADD_TO_SO_WITHIN_RO');
        l_ro_add_to_order_flag := nvl(l_ro_add_to_order_flag, 'N');

        Csd_Process_Util.BUILD_PROD_TXN_TBL(p_repair_line_id => p_repair_line_id,
											p_create_thirdpty_line => p_create_thirdpty_line,
                                            x_prod_txn_tbl   => x_prod_txn_tbl,
                                            x_return_status  => x_return_status);

        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('x_prod_txn_tbl.count =' ||
                                    x_prod_txn_tbl.COUNT);
        END IF;

        IF x_prod_txn_tbl.COUNT > 0 THEN
          FOR i IN x_prod_txn_tbl.first..1
          LOOP

             IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD('Call create_product_txn in a loop');
             END IF;
             CREATE_PRODUCT_TXN
             (p_api_version           =>  1.0 ,
              p_commit                =>  fnd_api.g_false,
              p_init_msg_list         =>  'F',
              p_validation_level      =>  fnd_api.g_valid_level_full,
              x_product_txn_rec       =>  x_prod_txn_tbl(i),
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data  );

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- Log the message after processing
              -- each prod txn
              FOR i in 1..x_msg_Count LOOP
                   FND_MSG_PUB.Get
                           (p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
                   l_msg_text := x_msg_data;
                   IF (g_debug > 0 ) THEN
                      csd_gen_utility_pvt.ADD('message data after create_prod_txn ='||x_msg_data);
                   END IF;
              End LOOP;
          END LOOP;

          FOR i IN 2..x_prod_txn_tbl.last
          LOOP

             IF (g_debug > 0 ) THEN
                csd_gen_utility_pvt.ADD('Call create_product_txn in a loop 2');
             END IF;

             If ((i = 2) and (x_prod_txn_tbl(i).interface_to_om_flag = 'Y') and
                 (x_prod_txn_tbl(i).new_order_flag = 'Y' or x_prod_txn_tbl(i).new_order_flag is null) and
                 ((l_sr_add_to_order_flag = 'Y') or (l_ro_add_to_order_flag = 'Y'))) Then

                  l_add_rma_to_id := CSD_PROCESS_UTIL.get_sr_add_to_order(p_repair_line_Id, 'RMA');
                  l_add_ship_to_id := CSD_PROCESS_UTIL.get_sr_add_to_order(p_repair_line_Id, 'SHIP');
                  If (x_prod_txn_tbl(i).action_type = 'SHIP' and (l_add_ship_to_id is not null)) Then
	                   x_prod_txn_tbl(i).new_order_flag := 'N';
	                   x_prod_txn_tbl(i).add_to_order_flag := 'Y';
	                   x_prod_txn_tbl(i).add_to_order_id := l_add_ship_to_id;
                  elsif (x_prod_txn_tbl(i).action_type = 'RMA' and (l_add_rma_to_id is not null)) Then
	                   x_prod_txn_tbl(i).new_order_flag := 'N';
	                   x_prod_txn_tbl(i).add_to_order_flag := 'Y';
	                   x_prod_txn_tbl(i).add_to_order_id := l_add_rma_to_id;
                  End If;

                  --special case
                  If ((NVL(x_prod_txn_tbl(1).interface_to_om_flag, 'N') = 'N') and (l_sr_add_to_order_flag = 'N')
                     and (l_ro_add_to_order_flag = 'Y')) Then
                        x_prod_txn_tbl(i).new_order_flag := 'Y';
                        x_prod_txn_tbl(i).add_to_order_flag := 'N';
                        x_prod_txn_tbl(i).add_to_order_id := null;
                  End if;

             END IF;

             CREATE_PRODUCT_TXN
             (p_api_version           =>  1.0 ,
              p_commit                =>  fnd_api.g_false,
              p_init_msg_list         =>  'F',
              p_validation_level      =>  fnd_api.g_valid_level_full,
              x_product_txn_rec       =>  x_prod_txn_tbl(i),
              x_return_status         =>  x_return_status,
              x_msg_count             =>  x_msg_count,
              x_msg_data              =>  x_msg_data  );

              IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- Log the message after processing
              -- each prod txn
              FOR i in 1..x_msg_Count LOOP
                   FND_MSG_PUB.Get
                           (p_msg_index     => i,
                            p_encoded       => 'F',
                            p_data          => x_msg_data,
                            p_msg_index_out => x_msg_index_out );
                   l_msg_text := x_msg_data;
                   IF (g_debug > 0 ) THEN
                      csd_gen_utility_pvt.ADD('message data after create_prod_txn ='||x_msg_data);
                   END IF;
              End LOOP;
          END LOOP;
       END IF;

        -- Api body ends here
        IF l_msg_text IS NOT NULL
        THEN
            Fnd_Message.SET_NAME('CSD', 'CSD_API_OM_ERR_MSG');
            Fnd_Message.SET_TOKEN('MSG_DATA', l_msg_text);
            Fnd_Msg_Pub.ADD;
        END IF;

        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO create_default_prod_txn;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_default_prod_txn;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_default_prod_txn;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_default_prod_txn;

    --------------------- travi changes---------------

    FUNCTION GET_ORG_REC_TYPE RETURN HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE IS
        TMP_ORG_REC_TYPE HZ_PARTY_V2PUB.ORGANIZATION_REC_TYPE;
    BEGIN
        RETURN TMP_ORG_REC_TYPE;
    END GET_ORG_REC_TYPE;
    FUNCTION GET_GROUP_REC_TYPE RETURN HZ_PARTY_V2PUB.GROUP_REC_TYPE IS
        TMP_GROUP_REC_TYPE HZ_PARTY_V2PUB.GROUP_REC_TYPE;
    BEGIN
        RETURN TMP_GROUP_REC_TYPE;
    END GET_GROUP_REC_TYPE;
    FUNCTION GET_PARTY_REC_TYPE RETURN HZ_PARTY_V2PUB.PARTY_REC_TYPE IS
        TMP_PARTY_REC_TYPE HZ_PARTY_V2PUB.PARTY_REC_TYPE;
    BEGIN
        RETURN TMP_PARTY_REC_TYPE;
    END GET_PARTY_REC_TYPE;
    FUNCTION GET_PERSON_REC_TYPE RETURN HZ_PARTY_V2PUB.PERSON_REC_TYPE IS
        TMP_PERSON_REC_TYPE HZ_PARTY_V2PUB.PERSON_REC_TYPE;
    BEGIN
        RETURN TMP_PERSON_REC_TYPE;
    END GET_PERSON_REC_TYPE;
    FUNCTION GET_CONTACT_POINTS_REC_TYPE
        RETURN HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE IS
        TMP_CONTACT_POINTS_REC_TYPE HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
    BEGIN
        RETURN TMP_CONTACT_POINTS_REC_TYPE;
    END GET_CONTACT_POINTS_REC_TYPE;
    FUNCTION GET_EDI_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE IS
        TMP_EDI_REC_TYPE HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
    BEGIN
        RETURN TMP_EDI_REC_TYPE;
    END GET_EDI_REC_TYPE;
    FUNCTION GET_PHONE_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE IS
        TMP_PHONE_REC_TYPE HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
    BEGIN
        RETURN TMP_PHONE_REC_TYPE;
    END GET_PHONE_REC_TYPE;
    FUNCTION GET_EMAIL_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE IS
        TMP_EMAIL_REC_TYPE HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
    BEGIN
        RETURN TMP_EMAIL_REC_TYPE;
    END GET_EMAIL_REC_TYPE;
    FUNCTION GET_TELEX_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE IS
        TMP_TELEX_REC_TYPE HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
    BEGIN
        RETURN TMP_TELEX_REC_TYPE;
    END GET_TELEX_REC_TYPE;
    FUNCTION GET_WEB_REC_TYPE RETURN HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE IS
        TMP_WEB_REC_TYPE HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
    BEGIN
        RETURN TMP_WEB_REC_TYPE;
    END GET_WEB_REC_TYPE;
    FUNCTION GET_ACCOUNT_REC_TYPE
        RETURN HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE IS
        TMP_ACCOUNT_REC_TYPE HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
    BEGIN
        RETURN TMP_ACCOUNT_REC_TYPE;
    END GET_ACCOUNT_REC_TYPE;
    FUNCTION GET_PARTY_REL_REC_TYPE RETURN HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE IS
        TMP_PARTY_REL_REC_TYPE HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
    BEGIN
        RETURN TMP_PARTY_REL_REC_TYPE;
    END GET_PARTY_REL_REC_TYPE;
    FUNCTION GET_ORG_CONTACT_REC_TYPE RETURN HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE IS
        TMP_ORG_CONTACT_REC_TYPE HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
    BEGIN
        RETURN TMP_ORG_CONTACT_REC_TYPE;
    END GET_ORG_CONTACT_REC_TYPE;
    FUNCTION GET_PARTY_SITE_REC_TYPE RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE IS
        TMP_PARTY_SITE_REC_TYPE HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
    BEGIN
        RETURN TMP_PARTY_SITE_REC_TYPE;
    END GET_PARTY_SITE_REC_TYPE;
    FUNCTION GET_PARTY_SITE_USE_REC_TYPE
        RETURN HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE IS
        TMP_PARTY_SITE_USE_REC_TYPE HZ_PARTY_SITE_V2PUB.PARTY_SITE_USE_REC_TYPE;
    BEGIN
        RETURN TMP_PARTY_SITE_USE_REC_TYPE;
    END GET_PARTY_SITE_USE_REC_TYPE;
    FUNCTION GET_CUST_PROFILE_REC_TYPE
        RETURN HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE IS
        TMP_CUST_PROFILE_REC_TYPE HZ_CUSTOMER_PROFILE_V2PUB.CUSTOMER_PROFILE_REC_TYPE;
    BEGIN
        RETURN TMP_CUST_PROFILE_REC_TYPE;
    END GET_CUST_PROFILE_REC_TYPE;
    FUNCTION GET_CREATE_TASK_REC_TYPE
        RETURN Csd_Process_Pvt.CREATE_TASK_REC_TYPE IS
        TMP_CREATE_TASK_REC_TYPE Csd_Process_Pvt.CREATE_TASK_REC_TYPE;
    BEGIN
        RETURN TMP_CREATE_TASK_REC_TYPE;
    END GET_CREATE_TASK_REC_TYPE;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: create_task                                                                               */
    /* description   : procedure used to create task                                                             */
    /* Called from   : Depot Repair Form to Create Task                                                          */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 CREATE_TASK_REC_TYPE  RECORD      Required Columns are in the Record CREATE_TASK_REC_TYPE */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*                 x_task_id             NUMBER               Task Id of the created Task                    */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE create_task(p_api_version      IN NUMBER,
                          p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                          p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                          p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                          p_create_task_rec  IN CREATE_TASK_REC_TYPE,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2,
                          x_task_id          OUT NOCOPY NUMBER) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_TASK';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);
        l_msg_index     NUMBER;
        l_return_status VARCHAR2(1);
        l_task_id       NUMBER;
        -- Task record
        l_create_task_rec Csd_Process_Pvt.CREATE_TASK_REC_TYPE := p_create_task_rec;
    BEGIN
        -- -----------------
        -- Begin create task
        -- -----------------
        -- Standard Start of API savepoint
        SAVEPOINT create_task;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------
        -- Api body starts
        -- ---------------
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('CSD_PROCESS_PVT.create_task before jtf_tasks_pub.CREATE_TASK');
        END IF;

        -- ----------------------------------------
        -- Calling Public JTF API to create a Task
        -- ----------------------------------------
        Jtf_Tasks_Pub.CREATE_TASK(P_API_VERSION             => 1.0,
                                  P_INIT_MSG_LIST           => Fnd_Api.g_true,
                                  P_COMMIT                  => Fnd_Api.g_false,
                                  P_TASK_ID                 => l_create_task_rec.task_id,
                                  P_TASK_NAME               => l_create_task_rec.TASK_NAME,
                                  P_TASK_TYPE_ID            => l_create_task_rec.TASK_TYPE_ID,
                                  P_DESCRIPTION             => l_create_task_rec.DESCRIPTION,
                                  P_TASK_STATUS_ID          => l_create_task_rec.TASK_STATUS_ID,
                                  P_TASK_PRIORITY_ID        => l_create_task_rec.TASK_PRIORITY_ID,
                                  P_OWNER_TYPE_CODE         => l_create_task_rec.OWNER_TYPE_CODE,
                                  P_OWNER_ID                => l_create_task_rec.OWNER_ID,
                                  P_OWNER_TERRITORY_ID      => l_create_task_rec.OWNER_TERRITORY_ID,
                                  P_ASSIGNED_BY_ID          => l_create_task_rec.ASSIGNED_BY_ID,
                                  P_CUSTOMER_ID             => l_create_task_rec.CUSTOMER_ID,
                                  P_CUST_ACCOUNT_ID         => l_create_task_rec.CUST_ACCOUNT_ID,
                                  P_ADDRESS_ID              => l_create_task_rec.ADDRESS_ID,
                                  P_PLANNED_START_DATE      => l_create_task_rec.planned_start_date,
                                  P_PLANNED_END_DATE        => l_create_task_rec.planned_end_date,
                                  P_SCHEDULED_START_DATE    => l_create_task_rec.scheduled_start_date,
                                  P_SCHEDULED_END_DATE      => l_create_task_rec.scheduled_end_date,
                                  P_ACTUAL_START_DATE       => l_create_task_rec.actual_start_date,
                                  P_ACTUAL_END_DATE         => l_create_task_rec.actual_end_date,
                                  P_TIMEZONE_ID             => l_create_task_rec.TIMEZONE_ID,
                                  P_SOURCE_OBJECT_TYPE_CODE => l_create_task_rec.SOURCE_OBJECT_TYPE_CODE,
                                  P_SOURCE_OBJECT_ID        => l_create_task_rec.SOURCE_OBJECT_ID,
                                  P_SOURCE_OBJECT_NAME      => l_create_task_rec.SOURCE_OBJECT_NAME,
                                  P_DURATION                => l_create_task_rec.DURATION,
                                  P_DURATION_UOM            => l_create_task_rec.DURATION_UOM,
                                  P_PLANNED_EFFORT          => l_create_task_rec.PLANNED_EFFORT,
                                  P_PLANNED_EFFORT_UOM      => l_create_task_rec.PLANNED_EFFORT_UOM,
                                  P_ACTUAL_EFFORT           => l_create_task_rec.ACTUAL_EFFORT,
                                  P_ACTUAL_EFFORT_UOM       => l_create_task_rec.ACTUAL_EFFORT_UOM,
                                  P_PRIVATE_FLAG            => l_create_task_rec.PRIVATE_FLAG,
                                  P_PUBLISH_FLAG            => l_create_task_rec.PUBLISH_FLAG,
                                  P_RESTRICT_CLOSURE_FLAG   => l_create_task_rec.RESTRICT_CLOSURE_FLAG,
                                  P_ATTRIBUTE1              => l_create_task_rec.ATTRIBUTE1,
                                  P_ATTRIBUTE2              => l_create_task_rec.ATTRIBUTE2,
                                  P_ATTRIBUTE3              => l_create_task_rec.ATTRIBUTE3,
                                  P_ATTRIBUTE4              => l_create_task_rec.ATTRIBUTE4,
                                  P_ATTRIBUTE5              => l_create_task_rec.ATTRIBUTE5,
                                  P_ATTRIBUTE6              => l_create_task_rec.ATTRIBUTE6,
                                  P_ATTRIBUTE7              => l_create_task_rec.ATTRIBUTE7,
                                  P_ATTRIBUTE8              => l_create_task_rec.ATTRIBUTE8,
                                  P_ATTRIBUTE9              => l_create_task_rec.ATTRIBUTE9,
                                  P_ATTRIBUTE10             => l_create_task_rec.ATTRIBUTE10,
                                  P_ATTRIBUTE11             => l_create_task_rec.ATTRIBUTE11,
                                  P_ATTRIBUTE12             => l_create_task_rec.ATTRIBUTE12,
                                  P_ATTRIBUTE13             => l_create_task_rec.ATTRIBUTE13,
                                  P_ATTRIBUTE14             => l_create_task_rec.ATTRIBUTE14,
                                  P_ATTRIBUTE15             => l_create_task_rec.ATTRIBUTE15,
                                  P_ATTRIBUTE_CATEGORY      => l_create_task_rec.ATTRIBUTE_CATEGORY,
                                  P_BOUND_MODE_CODE         => l_create_task_rec.bound_mode_code,
                                  P_SOFT_BOUND_FLAG         => l_create_task_rec.soft_bound_flag,
                                  P_PARENT_TASK_ID          => l_create_task_rec.PARENT_TASK_ID,
                                  P_ESCALATION_LEVEL        => l_create_task_rec.ESCALATION_LEVEL,
                                  X_RETURN_STATUS           => x_return_status,
                                  X_MSG_COUNT               => x_msg_count,
                                  X_MSG_DATA                => x_msg_data,
                                  X_TASK_ID                 => x_task_id);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('CSD_PROCESS_PVT.create_task after jtf_tasks_pub.CREATE_TASK x_return_status' ||
                                    x_return_status);
        END IF;

        -- -------------------
        -- Api body ends here
        -- -------------------
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO create_task;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_task;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_task;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END create_task;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: update_task                                                                               */
    /* description   : procedure used to update task                                                             */
    /* Called from   : Depot Repair Form to Create Task                                                          */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 CREATE_TASK_REC_TYPE  RECORD      Required Columns are in the Record CREATE_TASK_REC_TYPE */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE update_task(p_api_version      IN NUMBER,
                          p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                          p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                          p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                          p_create_task_rec  IN CREATE_TASK_REC_TYPE,
                          x_return_status    OUT NOCOPY VARCHAR2,
                          x_msg_count        OUT NOCOPY NUMBER,
                          x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'UPDATE_TASK';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);
        l_msg_index     NUMBER;
        l_return_status VARCHAR2(1);
        l_task_id       NUMBER;
        -- Task record
        l_create_task_rec Csd_Process_Pvt.CREATE_TASK_REC_TYPE := p_create_task_rec;
    BEGIN
        -- -----------------
        -- Begin update task
        -- -----------------
        -- Standard Start of API savepoint
        SAVEPOINT update_task;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------
        -- Api body starts
        -- ---------------
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('CSD_PROCESS_PVT.update_task before jtf_tasks_pub.UPDATE_TASK');
        END IF;

        -- ----------------------------------------
        -- Calling Public JTF API to Update a Task
        -- ----------------------------------------
        Jtf_Tasks_Pub.UPDATE_TASK(P_API_VERSION             => 1.0,
                                  P_INIT_MSG_LIST           => Fnd_Api.g_true,
                                  P_COMMIT                  => Fnd_Api.g_false,
                                  P_TASK_ID                 => l_create_task_rec.task_id,
                                  P_TASK_NAME               => l_create_task_rec.TASK_NAME,
                                  P_TASK_TYPE_ID            => l_create_task_rec.TASK_TYPE_ID,
                                  P_DESCRIPTION             => l_create_task_rec.DESCRIPTION,
                                  P_TASK_STATUS_ID          => l_create_task_rec.TASK_STATUS_ID,
                                  P_TASK_PRIORITY_NAME      => l_create_task_rec.TASK_PRIORITY_NAME,
                                  P_TASK_PRIORITY_ID        => l_create_task_rec.TASK_PRIORITY_ID,
                                  P_OWNER_TYPE_CODE         => l_create_task_rec.OWNER_TYPE_CODE,
                                  P_OWNER_ID                => l_create_task_rec.OWNER_ID,
                                  P_OWNER_TERRITORY_ID      => l_create_task_rec.OWNER_TERRITORY_ID,
                                  P_ASSIGNED_BY_ID          => l_create_task_rec.ASSIGNED_BY_ID,
                                  P_CUSTOMER_ID             => l_create_task_rec.CUSTOMER_ID,
                                  P_CUST_ACCOUNT_ID         => l_create_task_rec.CUST_ACCOUNT_ID,
                                  P_ADDRESS_ID              => l_create_task_rec.ADDRESS_ID,
                                  P_PLANNED_START_DATE      => l_create_task_rec.planned_start_date,
                                  P_PLANNED_END_DATE        => l_create_task_rec.planned_end_date,
                                  P_SCHEDULED_START_DATE    => l_create_task_rec.scheduled_start_date,
                                  P_SCHEDULED_END_DATE      => l_create_task_rec.scheduled_end_date,
                                  P_ACTUAL_START_DATE       => l_create_task_rec.actual_start_date,
                                  P_ACTUAL_END_DATE         => l_create_task_rec.actual_end_date,
                                  P_TIMEZONE_ID             => l_create_task_rec.TIMEZONE_ID,
                                  P_SOURCE_OBJECT_TYPE_CODE => l_create_task_rec.SOURCE_OBJECT_TYPE_CODE,
                                  P_SOURCE_OBJECT_ID        => l_create_task_rec.SOURCE_OBJECT_ID,
                                  P_SOURCE_OBJECT_NAME      => l_create_task_rec.SOURCE_OBJECT_NAME,
                                  P_DURATION                => l_create_task_rec.DURATION,
                                  P_DURATION_UOM            => l_create_task_rec.DURATION_UOM,
                                  P_PLANNED_EFFORT          => l_create_task_rec.PLANNED_EFFORT,
                                  P_PLANNED_EFFORT_UOM      => l_create_task_rec.PLANNED_EFFORT_UOM,
                                  P_ACTUAL_EFFORT           => l_create_task_rec.ACTUAL_EFFORT,
                                  P_ACTUAL_EFFORT_UOM       => l_create_task_rec.ACTUAL_EFFORT_UOM,
                                  P_PRIVATE_FLAG            => l_create_task_rec.PRIVATE_FLAG,
                                  P_PUBLISH_FLAG            => l_create_task_rec.PUBLISH_FLAG,
                                  P_RESTRICT_CLOSURE_FLAG   => l_create_task_rec.RESTRICT_CLOSURE_FLAG,
                                  P_ATTRIBUTE1              => l_create_task_rec.ATTRIBUTE1,
                                  P_ATTRIBUTE2              => l_create_task_rec.ATTRIBUTE2,
                                  P_ATTRIBUTE3              => l_create_task_rec.ATTRIBUTE3,
                                  P_ATTRIBUTE4              => l_create_task_rec.ATTRIBUTE4,
                                  P_ATTRIBUTE5              => l_create_task_rec.ATTRIBUTE5,
                                  P_ATTRIBUTE6              => l_create_task_rec.ATTRIBUTE6,
                                  P_ATTRIBUTE7              => l_create_task_rec.ATTRIBUTE7,
                                  P_ATTRIBUTE8              => l_create_task_rec.ATTRIBUTE8,
                                  P_ATTRIBUTE9              => l_create_task_rec.ATTRIBUTE9,
                                  P_ATTRIBUTE10             => l_create_task_rec.ATTRIBUTE10,
                                  P_ATTRIBUTE11             => l_create_task_rec.ATTRIBUTE11,
                                  P_ATTRIBUTE12             => l_create_task_rec.ATTRIBUTE12,
                                  P_ATTRIBUTE13             => l_create_task_rec.ATTRIBUTE13,
                                  P_ATTRIBUTE14             => l_create_task_rec.ATTRIBUTE14,
                                  P_ATTRIBUTE15             => l_create_task_rec.ATTRIBUTE15,
                                  P_ATTRIBUTE_CATEGORY      => l_create_task_rec.ATTRIBUTE_CATEGORY,
                                  P_BOUND_MODE_CODE         => l_create_task_rec.bound_mode_code,
                                  P_SOFT_BOUND_FLAG         => l_create_task_rec.soft_bound_flag,
                                  P_PARENT_TASK_ID          => l_create_task_rec.PARENT_TASK_ID,
                                  P_ESCALATION_LEVEL        => l_create_task_rec.ESCALATION_LEVEL,
                                  P_OBJECT_VERSION_NUMBER   => l_create_task_rec.OBJECT_VERSION_NUMBER,
                                  X_RETURN_STATUS           => x_return_status,
                                  X_MSG_COUNT               => x_msg_count,
                                  X_MSG_DATA                => x_msg_data);

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('CSD_PROCESS_PVT.update_task after jtf_tasks_pub.UPDATE_TASK x_return_status' ||
                                    x_return_status);
        END IF;

        -- -------------------
        -- Api body ends here
        -- -------------------
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO update_task;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_task;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_task;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_task;
    FUNCTION GET_ADDRESS_REC_TYPE RETURN Csd_Process_Pvt.ADDRESS_REC_TYPE IS
        TMP_ADDRESS_REC_TYPE Csd_Process_Pvt.ADDRESS_REC_TYPE;
    BEGIN
        RETURN TMP_ADDRESS_REC_TYPE;
    END GET_ADDRESS_REC_TYPE;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: create_address                                                                            */
    /* description   : procedure to create Address for the Contact                                               */
    /* Called from   : Depot Repair Form to Create Address                                                       */
    /* Input Parm    : p_address_rec         RECORD      Required Record ADDRESS_REC_TYPE                        */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*                 x_location_id         NUMBER               Location ID of the Contacts address created    */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Create_Address(p_address_rec   IN ADDRESS_REC_TYPE,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_location_id   OUT NOCOPY NUMBER) IS
        l_location_rec  HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
        l_return_status VARCHAR2(1);
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);
        l_location_id   NUMBER;
    BEGIN
        l_location_rec.address1                     := p_address_rec.address1;
        l_location_rec.address2                     := p_address_rec.address2;
        l_location_rec.address3                     := p_address_rec.address3;
        l_location_rec.address4                     := p_address_rec.address4;
        l_location_rec.city                         := p_address_rec.city;
        l_location_rec.state                        := p_address_rec.state;
        l_location_rec.county                       := p_address_rec.county;
        l_location_rec.country                      := p_address_rec.country;
        l_location_rec.postal_code                  := p_address_rec.postal_code;
        l_location_rec.province                     := p_address_rec.province;
        l_location_rec.county                       := p_address_rec.county;
        l_location_rec.LANGUAGE                     := p_address_rec.LANGUAGE;
        l_location_rec.position                     := p_address_rec.position;
        l_location_rec.address_key                  := p_address_rec.address_key;
        l_location_rec.postal_plus4_code            := p_address_rec.postal_plus4_code;
        l_location_rec.position                     := p_address_rec.position;
        l_location_rec.delivery_point_code          := p_address_rec.delivery_point_code;
        l_location_rec.location_directions          := p_address_rec.location_directions;
        -- l_location_rec.address_error_code           := p_address_rec.address_error_code;
        l_location_rec.clli_code                    := p_address_rec.clli_code;
        l_location_rec.short_description            := p_address_rec.short_description;
        l_location_rec.description                  := p_address_rec.description;
        l_location_rec.sales_tax_geocode            := p_address_rec.sales_tax_geocode;
        l_location_rec.sales_tax_inside_city_limits := p_address_rec.sales_tax_inside_city_limits;
        -- swai: new TCA v2 fields
        l_location_rec.timezone_id                  := p_address_rec.timezone_id;
        l_location_rec.created_by_module            := p_address_rec.created_by_module;
        l_location_rec.application_id               := p_address_rec.application_id;
        l_location_rec.actual_content_source        := p_address_rec.actual_content_source;
        -- swai: unused fields in TCA, but still avail in v2 (per bug #2863096)
        l_location_rec.po_box_number                := p_address_rec.po_box_number;
        l_location_rec.street                       := p_address_rec.street;
        l_location_rec.house_number                 := p_address_rec.house_number;
        l_location_rec.street_suffix                := p_address_rec.street_suffix;
        l_location_rec.street_number                := p_address_rec.street_number;
        l_location_rec.floor                        := p_address_rec.floor;
        l_location_rec.suite                        := p_address_rec.suite;
        -- swai: obsoleted v1 fields
        -- l_location_rec.apartment_number             := p_address_rec.apartment_number;
        -- l_location_rec.building                     := p_address_rec.building;
        -- l_location_rec.apartment_flag               := p_address_rec.apartment_flag;
        -- l_location_rec.secondary_suffix_element     := p_address_rec.secondary_suffix_element;
        -- l_location_rec.rural_route_type             := p_address_rec.rural_route_type;
        -- l_location_rec.rural_route_number           := p_address_rec.rural_route_number;
        -- l_location_rec.room                         := p_address_rec.room;
        -- l_location_rec.time_zone                    := p_address_rec.time_zone;
        -- l_location_rec.post_office                  := p_address_rec.post_office;
        -- l_location_rec.dodaac                       := p_address_rec.dodaac;
        -- l_location_rec.trailing_directory_code      := p_address_rec.trailing_directory_code;
        -- l_location_rec.life_cycle_status            := p_address_rec.life_cycle_status;
        -- l_location_rec.wh_update_date               := p_address_rec.wh_update_date;


        /*-----------------------------------------------------------------------------------------------------------*/
        /*   Calling HZ Public API to create location                                                                */
        /*   Description : Creates location.                                                                         */
        /*   Input Parm    :                                                                                         */
        /*                 p_api_version                                                                             */
        /*                 p_init_msg_list                                                                           */
        /*                 p_commit                                                                                  */
        /*                 p_location_rec                                                                            */
        /*                 p_validation_level                                                                        */
        /*   Output Parm   :                                                                                         */
        /*                 x_return_status                                                                           */
        /*                 x_msg_count                                                                               */
        /*                 x_msg_data                                                                                */
        /*                 x_location_id                                                                             */
        /*-----------------------------------------------------------------------------------------------------------*/
        HZ_LOCATION_V2PUB.create_location(p_init_msg_list    => Fnd_Api.G_FALSE,
                                        p_location_rec     => l_location_rec,
                                        x_location_id      => l_location_id,
                                        x_return_status    => l_return_status,
                                        x_msg_count        => l_msg_count,
                                        x_msg_data         => l_msg_data
                                        );
        x_return_status := l_return_status;
        x_msg_count     := l_msg_count;
        x_msg_data      := l_msg_data;
        IF x_return_status = Csc_Core_Utils_Pvt.G_RET_STS_SUCCESS
        THEN
            x_location_id := l_location_id;
        END IF;
    END Create_Address;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: Create_repair_task_hist                                                                   */
    /* description   : procedure used to create Repair Order history for task creation                           */
    /* Called from   : Depot Repair Form to Create Address                                                       */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 p_task_id             NUMBER      Required Task Id                                        */
    /*                 p_repair_line_id      NUMBER      Required Repair_line_id                                 */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Create_repair_task_hist(p_api_version      IN NUMBER,
                                      p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                      p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                      p_task_id          IN NUMBER,
                                      p_repair_line_id   IN NUMBER,
                                      x_return_status    OUT NOCOPY VARCHAR2,
                                      x_msg_count        OUT NOCOPY NUMBER,
                                      x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'VALIDATE_AND_WRITE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count         NUMBER;
        l_msg_data          VARCHAR2(2000);
        l_msg_index         NUMBER;
        l_return_status     VARCHAR2(1);
        l_repair_history_id NUMBER;
        l_paramn1           NUMBER;
        l_paramn2           NUMBER;
        l_paramn3           NUMBER;
        l_paramn4           NUMBER;
        l_paramn5           NUMBER;
        l_paramc1           VARCHAR2(240);
        l_paramc2           VARCHAR2(240);
        l_paramc3           VARCHAR2(240);
        l_paramc4           VARCHAR2(240);
        l_paramc5           VARCHAR2(240);
        l_paramc6           VARCHAR2(240);
        l_paramd1           DATE;
        l_paramd2           DATE;
        l_paramd3           DATE;
        l_paramd4           DATE;
        l_event_code        VARCHAR2(30) := 'TC'; -- Task Created
        l_check_task        NUMBER;
        CURSOR c_task(p_task_id NUMBER, p_repair_line_id NUMBER) IS
            SELECT tsk.task_id, -- hist.paramn1
                   tsk.last_updated_by, -- hist.paramn2
                   tsk.owner_id, -- hist.paramn3
                   tsk.assigned_by_id, -- hist.paramn4
                   tsk.task_status_id, -- hist.paramn5
                   tsk.task_number, -- hist.paramc1
                   tsk.owner_type, -- hist.paramc2
                   tsk.owner, -- hist.paramc3
                   NULL assignee_type, -- hist.paramc4
                   NULL assignee_name, -- hist.paramc5
                   tsk.task_status, -- hist.paramc6
                   tsk.planned_start_date, -- hist.paramd1
                   tsk.actual_start_date, -- hist.paramd2
                   tsk.actual_end_date, -- hist.paramd3
                   tsk.last_update_date -- hist.paramd4
              FROM CSD_REPAIR_TASKS_V tsk
             WHERE tsk.source_object_type_code = 'DR'
               AND tsk.source_object_id = p_repair_line_id
               AND tsk.task_id = p_task_id;
    BEGIN

        -- check if this task is saved in the repair history
        SELECT COUNT(*)
          INTO l_check_task
          FROM CSD_REPAIR_TASKS_V tsk, CSD_REPAIR_HISTORY hist
         WHERE tsk.source_object_id = hist.repair_line_id
           AND hist.paramn1 = p_task_id
           AND tsk.source_object_type_code = 'DR'
           AND hist.event_code = 'TC';

        IF (l_check_task > 0)
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Task Exists in Repair History');
            END IF;

        ELSE
            -- call the pub after assigning the required variable values
            OPEN c_task(p_task_id, p_repair_line_id);

            --      dbms_output.put_line('Task Cursor fetches data');
            FETCH c_task
                INTO l_paramn1, -- task id
            l_paramn2, -- last updated by
            l_paramn3, -- owner id
            l_paramn4, -- assigned by id
            l_paramn5, -- status id
            l_paramc1, -- task number
            l_paramc2, -- owner type
            l_paramc3, -- owner name
            l_paramc4, -- null assignee type
            l_paramc5, -- null assignee name
            l_paramc6, -- status
            l_paramd1, -- planned start date
            l_paramd2, -- actual start date
            l_paramd3, -- actual end date
            l_paramd4; -- last updated date
            --       dbms_output.put_line('Task Cursor has no data');

            CLOSE c_task;
            -- --------------------------------
            -- Begin create repair task history
            -- --------------------------------
            -- History       : assignee_id   --> assigned_by_id
            --                 assignee_type --> null
            --                 assignee_name --> null

            -- Standard Start of API savepoint
            SAVEPOINT Create_repair_task_hist;
            -- Standard call to check for call compatibility.
            IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
            THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Initialize message list if p_init_msg_list is set to TRUE.
            IF Fnd_Api.to_Boolean(p_init_msg_list)
            THEN
                Fnd_Msg_Pub.initialize;
            END IF;
            -- Initialize API return status to success
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            -- ---------------
            -- Api body starts
            -- ---------------
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Before Task to Repair History API call');
            END IF;

            -- travi 020502 OBJECT_VERSION_NUMBER validation

            -- ------------------------------------------------------
            -- Internal Private API call to write to Repair History
            -- ------------------------------------------------------
            Csd_To_Form_Repair_History.Validate_And_Write(p_Api_Version_Number     => 1.0,
                                                          p_init_msg_list          => 'F',
                                                          p_commit                 => 'F',
                                                          p_validation_level       => NULL,
                                                          p_action_code            => 0,
                                                          px_REPAIR_HISTORY_ID     => l_repair_history_id,
                                                          p_OBJECT_VERSION_NUMBER  => NULL,
                                                          p_REQUEST_ID             => NULL,
                                                          p_PROGRAM_ID             => NULL,
                                                          p_PROGRAM_APPLICATION_ID => NULL,
                                                          p_PROGRAM_UPDATE_DATE    => NULL,
                                                          p_CREATED_BY             => Fnd_Global.USER_ID,
                                                          p_CREATION_DATE          => SYSDATE,
                                                          p_LAST_UPDATED_BY        => Fnd_Global.USER_ID,
                                                          p_LAST_UPDATE_DATE       => SYSDATE,
                                                          p_repair_line_id         => p_repair_line_id,
                                                          p_EVENT_CODE             => l_event_code,
                                                          p_EVENT_DATE             => SYSDATE,
                                                          p_QUANTITY               => NULL,
                                                          p_PARAMN1                => l_paramn1,
                                                          p_PARAMN2                => l_paramn2,
                                                          p_PARAMN3                => l_paramn3,
                                                          p_PARAMN4                => l_paramn4,
                                                          p_PARAMN5                => l_paramn5,
                                                          p_PARAMN6                => NULL,
                                                          p_PARAMN7                => NULL,
                                                          p_PARAMN8                => NULL,
                                                          p_PARAMN9                => NULL,
                                                          p_PARAMN10               => Fnd_Global.USER_ID,
                                                          p_PARAMC1                => l_paramc1,
                                                          p_PARAMC2                => l_paramc2,
                                                          p_PARAMC3                => l_paramc3,
                                                          p_PARAMC4                => l_paramc4,
                                                          p_PARAMC5                => l_paramc5,
                                                          p_PARAMC6                => l_paramc6,
                                                          p_PARAMC7                => NULL,
                                                          p_PARAMC8                => NULL,
                                                          p_PARAMC9                => NULL,
                                                          p_PARAMC10               => NULL,
                                                          p_PARAMD1                => l_paramd1,
                                                          p_PARAMD2                => l_paramd1,
                                                          p_PARAMD3                => l_paramd1,
                                                          p_PARAMD4                => l_paramd1,
                                                          p_PARAMD5                => NULL,
                                                          p_PARAMD6                => NULL,
                                                          p_PARAMD7                => NULL,
                                                          p_PARAMD8                => NULL,
                                                          p_PARAMD9                => NULL,
                                                          p_PARAMD10               => NULL,
                                                          p_ATTRIBUTE_CATEGORY     => NULL,
                                                          p_ATTRIBUTE1             => NULL,
                                                          p_ATTRIBUTE2             => NULL,
                                                          p_ATTRIBUTE3             => NULL,
                                                          p_ATTRIBUTE4             => NULL,
                                                          p_ATTRIBUTE5             => NULL,
                                                          p_ATTRIBUTE6             => NULL,
                                                          p_ATTRIBUTE7             => NULL,
                                                          p_ATTRIBUTE8             => NULL,
                                                          p_ATTRIBUTE9             => NULL,
                                                          p_ATTRIBUTE10            => NULL,
                                                          p_ATTRIBUTE11            => NULL,
                                                          p_ATTRIBUTE12            => NULL,
                                                          p_ATTRIBUTE13            => NULL,
                                                          p_ATTRIBUTE14            => NULL,
                                                          p_ATTRIBUTE15            => NULL,
                                                          p_LAST_UPDATE_LOGIN      => Fnd_Global.CONC_LOGIN_ID,
                                                          X_Return_Status          => x_return_status,
                                                          X_Msg_Count              => x_msg_count,
                                                          X_Msg_Data               => x_msg_data);
            --
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('After Task to Repair History : ' ||
                                        x_return_status);
            END IF;

            -- -------------------
            -- Api body ends here
            -- -------------------
            -- Standard check of p_commit.
            IF Fnd_Api.To_Boolean(p_commit)
            THEN
                COMMIT WORK;
            END IF;

            -- Standard call to get message count and IF count is  get message info.
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Create_repair_task_hist;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Create_repair_task_hist;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Create_repair_task_hist;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END Create_repair_task_hist;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: Update_repair_task_hist                                                                   */
    /* description   : procedure used to Update Repair Order history                                             */
    /*                 for task creation                                                                         */
    /* Called from   : Depot Repair Form to update to Repair history                                             */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 p_task_id             NUMBER      Required Task Id                                        */
    /*                 p_repair_line_id      NUMBER      Required Repair_line_id                                 */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*-----------------------------------------------------------------------------------------------------------*/
    /*
    PROCEDURE Update_repair_task_hist
    ( p_api_version           IN     NUMBER,
      p_init_msg_list         IN     VARCHAR2             := fnd_api.g_true,
      p_commit                IN     VARCHAR2             := fnd_api.g_false,
      p_validation_level      IN     NUMBER               := fnd_api.g_valid_level_full,
      p_task_id               IN     NUMBER,
      p_repair_line_id        IN     NUMBER,
      x_return_status         OUT NOCOPY    VARCHAR2,
      x_msg_count             OUT NOCOPY    NUMBER,
      x_msg_data              OUT NOCOPY    VARCHAR2
    )
        IS
        l_api_name               CONSTANT VARCHAR2(30)   := 'VALIDATE_AND_WRITE';
        l_api_version            CONSTANT NUMBER         := 1.0;
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(2000);
        l_msg_index              NUMBER;
        l_return_status          VARCHAR2(1);
        l_repair_history_id      NUMBER;
        l_paramn1                NUMBER;
        l_paramn2                NUMBER;
        l_paramn3                NUMBER;
        l_paramn4                NUMBER;
        l_paramn5                NUMBER;
        l_paramc1                VARCHAR2(240);
        l_paramc2                VARCHAR2(240);
        l_paramc3                VARCHAR2(240);
        l_paramc4                VARCHAR2(240);
        l_paramc5                VARCHAR2(240);
        l_paramc6                VARCHAR2(240);
        l_paramd1                DATE;
        l_paramd2                DATE;
        l_paramd3                DATE;
        l_paramd4                DATE;
        l_event_code             VARCHAR2(30)   := '';
        l_hist_ec                VARCHAR2(30);
        l_owner_type             VARCHAR2(240);
        l_owner                  VARCHAR2(240);
        l_assignee_type          VARCHAR2(240);
        l_assignee_name          VARCHAR2(240);
        l_task_status            VARCHAR2(240);
        l_check_id               NUMBER;
        l_check_code             VARCHAR2(30);

        CURSOR c_task_hist(p_task_id NUMBER, p_repair_line_id NUMBER) IS
          SELECT hist.event_code,
                 hist.paramc2,      -- tsk.owner_type
                 hist.paramc3,      -- tsk.owner
                 null paramc4,      -- tsk.assignee_type
                 null paramc5,      -- tsk.assignee_name
                 hist.paramc6       -- tsk.task_status
            FROM CSD_REPAIR_HISTORY hist
           WHERE hist.paramn1                = p_task_id
             AND hist.repair_line_id         = p_repair_line_id
         --and hist.event_code             = 'TC'
        ORDER BY hist.repair_history_id DESC;

        CURSOR c_task(p_task_id NUMBER, p_repair_line_id NUMBER) IS
          SELECT tsk.task_id,            -- hist.paramn1
                 tsk.last_updated_by,    -- hist.paramn2
                 tsk.owner_id,           -- hist.paramn3
                 tsk.assigned_by_id,        -- hist.paramn4
                 tsk.task_status_id,     -- hist.paramn5
                 tsk.task_number,        -- hist.paramc1
                 tsk.owner_type,         -- hist.paramc2
                 tsk.owner,              -- hist.paramc3
                 null assignee_type,      -- hist.paramc4
                 null assignee_name,      -- hist.paramc5
                 tsk.task_status,        -- hist.paramc6
                 tsk.planned_start_date, -- hist.paramd1
                 tsk.actual_start_date,  -- hist.paramd2
                 tsk.actual_end_date,    -- hist.paramd3
                 tsk.last_update_date    -- hist.paramd4
          FROM  CSD_REPAIR_TASKS_V tsk
         WHERE  tsk.source_object_type_code = 'DR'
           AND  tsk.source_object_id        = p_repair_line_id
           AND  tsk.task_id                 = p_task_id;

      BEGIN
          -- History       : assignee_id   --> assigned_by_id
          --                 assignee_type --> null
          --                 assignee_name --> null
          -- check if this task creation / update is saved in the repair history
          SELECT COUNT(*)
            INTO l_check_id
            FROM CSD_REPAIR_TASKS_V tsk,
             CSD_REPAIR_HISTORY hist
           WHERE tsk.source_object_id        = p_repair_line_id
         AND hist.paramn1                = p_task_id
             AND tsk.task_id                 = hist.paramn1
             AND tsk.source_object_id        = hist.repair_line_id
         AND tsk.source_object_type_code = 'DR';

           OPEN c_task(p_task_id, p_repair_line_id);

           FETCH c_task
           INTO  l_paramn1, -- task id
                 l_paramn2, -- last updated by
                 l_paramn3, -- owner id
                 l_paramn4, -- assigned by id
                 l_paramn5, -- status id
                 l_paramc1, -- task number
                 l_paramc2, -- owner type
                 l_paramc3, -- owner name
                 l_paramc4, -- null assignee type
                 l_paramc5, -- null assignee name
                 l_paramc6, -- status
                 l_paramd1, -- planned start date
                 l_paramd2, -- actual start date
                 l_paramd3, -- actual end date
                 l_paramd4; -- last updated date
           CLOSE c_task;
             -- TC Exists in Repair History
             -- add the update TOC/TSC line to Repair history
             -- ----------------------------------------------
             IF (l_check_id >= 1) THEN
               IF (g_debug > 0 ) THEN
                 csd_gen_utility_pvt.ADD('TC and/or TOC/TSC Exists in Repair History');
               END IF;

               -- pick latest row from Repair history
               OPEN c_task_hist(p_task_id, p_repair_line_id);

               FETCH c_task_hist
                INTO l_hist_ec,
                     l_owner_type,
                     l_owner,
                     l_assignee_type,
                     l_assignee_name,
                     l_task_status;

              CLOSE c_task_hist;
               -- check the row in history against the row in tasks
               -- for updates to Owner or Status
               -- check if Status has changed
               IF (l_task_status <> l_paramc6) THEN
                  -- insert Status change into Repair history
                  l_event_code := 'TSC';
               -- check if Owner has changed
               ELSIF (l_owner <> l_paramc3) THEN
                   -- insert Owner change into Repair history
                   l_event_code := 'TOC';
               ELSE
                   -- NO insert for this change into Repair history
                   l_event_code := '';
               END IF;
             END IF; -- check for l_check_id
             -- ----------------------------------------------
       -- ---------------------------------------------------------
       -- Repair history row inserted for TOC or TSC only
       -- ---------------------------------------------------------
       IF (l_event_code IN ('TOC', 'TSC')) THEN
          -- --------------------------------
          -- Begin create repair task history
          -- --------------------------------
          -- Standard Start of API savepoint
             SAVEPOINT  Update_repair_task_hist;
          -- Standard call to check for call compatibility.
             IF NOT FND_API.Compatible_API_Call (l_api_version,
                                                 p_api_version,
                                                 l_api_name   ,
                                                 G_PKG_NAME    )
             THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          -- Initialize message list if p_init_msg_list is set to TRUE.
             IF FND_API.to_Boolean( p_init_msg_list ) THEN
                   FND_MSG_PUB.initialize;
             END IF;
          -- Initialize API return status to success
             x_return_status := FND_API.G_RET_STS_SUCCESS;
          -- ---------------
          -- Api body starts
          -- ---------------
          IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('Before Task to Update Repair History');
          END IF;


          -- travi 020502 OBJECT_VERSION_NUMBER validation

           -- ------------------------------------------------------
           -- Internal Private API call to write to Repair History
           -- ------------------------------------------------------
          CSD_TO_FORM_REPAIR_HISTORY.Validate_And_Write
          (p_Api_Version_Number       => 1.0 ,
           p_init_msg_list            => 'F',
           p_commit                   => 'F',
           p_validation_level         => NULL,
           p_action_code              => 0,
           px_REPAIR_HISTORY_ID       => l_repair_history_id,
           p_OBJECT_VERSION_NUMBER    => NULL,
           p_REQUEST_ID               => NULL,
           p_PROGRAM_ID               => NULL,
           p_PROGRAM_APPLICATION_ID   => NULL,
           p_PROGRAM_UPDATE_DATE      => NULL,
           p_CREATED_BY               => FND_GLOBAL.USER_ID,
           p_CREATION_DATE            => SYSDATE,
           p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
           p_LAST_UPDATE_DATE         => SYSDATE,
           p_repair_line_id           => p_repair_line_id,
           p_EVENT_CODE               => l_event_code,
           p_EVENT_DATE               => SYSDATE,
           p_QUANTITY                 => NULL,
           p_PARAMN1                  => l_paramn1,
           p_PARAMN2                  => l_paramn2,
           p_PARAMN3                  => l_paramn3,
           p_PARAMN4                  => l_paramn4,
           p_PARAMN5                  => l_paramn5,
           p_PARAMN6                  => NULL,
           p_PARAMN7                  => NULL,
           p_PARAMN8                  => NULL,
           p_PARAMN9                  => NULL,
           p_PARAMN10                 => FND_GLOBAL.USER_ID,
           p_PARAMC1                  => l_paramc1,
           p_PARAMC2                  => l_paramc2,
           p_PARAMC3                  => l_paramc3,
           p_PARAMC4                  => l_paramc4,
           p_PARAMC5                  => l_paramc5,
           p_PARAMC6                  => l_paramc6,
           p_PARAMC7                  => NULL,
           p_PARAMC8                  => NULL,
           p_PARAMC9                  => NULL,
           p_PARAMC10                 => NULL,
           p_PARAMD1                  => l_paramd1,
           p_PARAMD2                  => l_paramd1,
           p_PARAMD3                  => l_paramd1,
           p_PARAMD4                  => l_paramd1,
           p_PARAMD5                  => NULL,
           p_PARAMD6                  => NULL,
           p_PARAMD7                  => NULL,
           p_PARAMD8                  => NULL,
           p_PARAMD9                  => NULL,
           p_PARAMD10                 => NULL,
           p_ATTRIBUTE_CATEGORY       => NULL,
           p_ATTRIBUTE1               => NULL,
           p_ATTRIBUTE2               => NULL,
           p_ATTRIBUTE3               => NULL,
           p_ATTRIBUTE4               => NULL,
           p_ATTRIBUTE5               => NULL,
           p_ATTRIBUTE6               => NULL,
           p_ATTRIBUTE7               => NULL,
           p_ATTRIBUTE8               => NULL,
           p_ATTRIBUTE9               => NULL,
           p_ATTRIBUTE10              => NULL,
           p_ATTRIBUTE11              => NULL,
           p_ATTRIBUTE12              => NULL,
           p_ATTRIBUTE13              => NULL,
           p_ATTRIBUTE14              => NULL,
           p_ATTRIBUTE15              => NULL,
           p_LAST_UPDATE_LOGIN        => FND_GLOBAL.CONC_LOGIN_ID,
           X_Return_Status            => x_return_status,
           X_Msg_Count                => x_msg_count,
           X_Msg_Data                 => x_msg_data
          );
        --
          IF (g_debug > 0 ) THEN
            csd_gen_utility_pvt.ADD('After Task to Update Repair History : '||x_return_status);
          END IF;

          -- -------------------
          -- Api body ends here
          -- -------------------
          -- Standard check of p_commit.
            IF FND_API.To_Boolean( p_commit ) THEN
                 COMMIT WORK;
            END IF;
          -- Standard call to get message count and IF count is  get message info.
            FND_MSG_PUB.Count_And_Get
                 (p_count  =>  x_msg_count,
                  p_data   =>  x_msg_data );
       END IF;
       -- ---------------------------------------------------------
       EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO Update_repair_task_hist;
                x_return_status := FND_API.G_RET_STS_ERROR ;
                FND_MSG_PUB.Count_And_Get
                    (p_count  =>  x_msg_count,
                     p_data   =>  x_msg_data
                    );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Update_repair_task_hist;
              FND_MSG_PUB.Count_And_Get
                    ( p_count  =>  x_msg_count,
                      p_data   =>  x_msg_data
                    );
          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              ROLLBACK TO Update_repair_task_hist;
                  IF  FND_MSG_PUB.Check_Msg_Level
                      (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                  THEN
                      FND_MSG_PUB.Add_Exc_Msg
                      (G_PKG_NAME ,
                       l_api_name  );
                  END IF;
                      FND_MSG_PUB.Count_And_Get
                      (p_count  =>  x_msg_count,
                       p_data   =>  x_msg_data );
      END Update_repair_task_hist;
    */
    -------------------- travi changes-------------

    PROCEDURE Create_repair_task_hist(p_api_version       IN NUMBER,
                                      p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_true,
                                      p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                      p_task_activity_rec IN Csd_Process_Pvt.TASK_ACTIVITY_REC,
                                      x_return_status     OUT NOCOPY VARCHAR2,
                                      x_msg_count         OUT NOCOPY NUMBER,
                                      x_msg_data          OUT NOCOPY VARCHAR2)

     IS
        l_api_name    CONSTANT VARCHAR2(30) := 'VALIDATE_AND_WRITE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
        l_return_status      VARCHAR2(1);
        l_repair_history_id  NUMBER;
        l_owner_type         VARCHAR2(240);
        l_owner              VARCHAR2(240);
        l_assignee_type      VARCHAR2(240);
        l_assignee_name      VARCHAR2(240);
        l_task_status        VARCHAR2(240);
        l_last_updated_by    NUMBER;
        l_assigned_by_id     NUMBER;
        l_task_number        VARCHAR2(240);
        l_task_name          VARCHAR2(240);
        l_planned_start_Date DATE;
        l_actual_start_Date  DATE;
        l_actual_end_Date    DATE;
        l_last_update_date   DATE;
        l_event_code         VARCHAR2(30) := 'TC'; -- Task Created
        l_check_task         NUMBER;

        /*CURSOR c_task(p_task_id NUMBER, p_repair_line_id NUMBER) IS
         SELECT tsk.task_id,            -- hist.paramn1
                tsk.last_updated_by,    -- hist.paramn2
                tsk.owner_id,           -- hist.paramn3
                tsk.assigned_by_id,     -- hist.paramn4
                tsk.task_status_id,     -- hist.paramn5
                tsk.task_number,        -- hist.paramc1
                tsk.owner_type,         -- hist.paramc2
                tsk.owner,              -- hist.paramc3
                --null assignee_type,   -- hist.paramc4
                --null assignee_name,   -- hist.paramc5
                tsk.task_status,        -- hist.paramc6
                tsk.task_name,          -- hist.paramc7
                tsk.planned_start_date, -- hist.paramd1
                tsk.actual_start_date,  -- hist.paramd2
                tsk.actual_end_date,    -- hist.paramd3
                tsk.last_update_date    -- hist.paramd4

         FROM  CSD_REPAIR_TASKS_V tsk
        WHERE  tsk.source_object_type_code = 'DR'
          AND  tsk.source_object_id        = p_repair_line_id
          AND  tsk.task_id                 = p_task_id;*/

        CURSOR c_task(p_task_id NUMBER, p_repair_line_id NUMBER) IS
            SELECT

             tsk.last_updated_by, -- hist.paramn2

             tsk.assigned_by_id, -- hist.paramn4

             tsk.task_number, -- hist.paramc1
             tsk.task_name,

             tsk.planned_start_date, -- hist.paramd1
             tsk.actual_start_date, -- hist.paramd2
             tsk.actual_end_date, -- hist.paramd3
             tsk.last_update_date -- hist.paramd4
              FROM CSD_REPAIR_TASKS_V tsk
             WHERE tsk.source_object_type_code = 'DR'
               AND tsk.source_object_id = p_repair_line_id
               AND tsk.task_id = p_task_id;

    BEGIN

        -- check if this task is saved in the repair history
        SELECT COUNT(*)
          INTO l_check_task
          FROM CSD_REPAIR_TASKS_V tsk, CSD_REPAIR_HISTORY hist
         WHERE tsk.source_object_id = hist.repair_line_id
           AND hist.paramn1 = p_task_activity_rec.task_id
           AND tsk.source_object_type_code = 'DR'
           AND hist.event_code = 'TC';

        IF (l_check_task > 0)
        THEN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Task Exists in Repair History');
            END IF;

        ELSE
            -- call the pub after assigning the required variable values
            OPEN c_task(p_task_activity_rec.task_id,
                        p_task_activity_rec.repair_line_id);

            --      dbms_output.put_line('Task Cursor fetches data');
            FETCH c_task
                INTO

            l_last_updated_by, -- last updated by
            l_assigned_by_id, -- assigned by id
            l_task_number, -- task number
            l_task_name, -- task name
            l_planned_start_Date, -- planned start date
            l_actual_start_Date, -- actual start date
            l_actual_end_Date, -- actual end date
            l_last_update_date; -- last updated date

            /*  l_paramn1, -- task id
             l_paramn2, -- last updated by
             l_paramn3, -- owner id
             l_paramn4, -- assigned by id
             l_paramn5, -- status id
             l_paramc1, -- task number
             l_paramc2, -- owner type sangiguptask
             l_paramc3, -- owner name
             --l_paramc4, -- null assignee type
            -- l_paramc5, -- null assignee name
             l_paramc6, -- status
             l_paramc7, -- task name
             l_paramd1, -- planned start date
             l_paramd2, -- actual start date
             l_paramd3, -- actual end date
             l_paramd4-- last updated date;*/

            --       dbms_output.put_line('Task Cursor has no data');

            CLOSE c_task;

            -- --------------------------------
            -- Begin create repair task history
            -- --------------------------------

            -- Standard Start of API savepoint
            SAVEPOINT Create_repair_task_hist;
            -- Standard call to check for call compatibility.
            IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                               p_api_version,
                                               l_api_name,
                                               G_PKG_NAME)
            THEN
                RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
            END IF;
            -- Initialize message list if p_init_msg_list is set to TRUE.
            IF Fnd_Api.to_Boolean(p_init_msg_list)
            THEN
                Fnd_Msg_Pub.initialize;
            END IF;
            -- Initialize API return status to success
            x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
            -- ---------------
            -- Api body starts
            -- ---------------
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Before Task to Repair History API call');
            END IF;

            -- travi 020502 OBJECT_VERSION_NUMBER validation

            -- ------------------------------------------------------
            -- Internal Private API call to write to Repair History
            -- ------------------------------------------------------
            Csd_To_Form_Repair_History.Validate_And_Write(p_Api_Version_Number     => 1.0,
                                                          p_init_msg_list          => 'F',
                                                          p_commit                 => 'F',
                                                          p_validation_level       => NULL,
                                                          p_action_code            => 0,
                                                          px_REPAIR_HISTORY_ID     => l_repair_history_id,
                                                          p_OBJECT_VERSION_NUMBER  => NULL,
                                                          p_REQUEST_ID             => NULL,
                                                          p_PROGRAM_ID             => NULL,
                                                          p_PROGRAM_APPLICATION_ID => NULL,
                                                          p_PROGRAM_UPDATE_DATE    => NULL,
                                                          p_CREATED_BY             => Fnd_Global.USER_ID,
                                                          p_CREATION_DATE          => SYSDATE,
                                                          p_LAST_UPDATED_BY        => Fnd_Global.USER_ID,
                                                          p_LAST_UPDATE_DATE       => SYSDATE,
                                                          p_repair_line_id         => p_task_activity_rec.repair_line_id,
                                                          p_EVENT_CODE             => l_event_code,
                                                          p_EVENT_DATE             => SYSDATE,
                                                          p_QUANTITY               => NULL,
                                                          p_PARAMN1                => p_task_activity_rec.task_id, --task id,
                                                          p_PARAMN2                => l_last_updated_by, --l_paramn2,
                                                          p_PARAMN3                => p_task_activity_rec.new_owner_id, --l_paramn3,
                                                          p_PARAMN4                => l_assigned_by_id, --l_paramn4,
                                                          p_PARAMN5                => p_task_activity_rec.new_status_id, --l_paramn5,
                                                          p_PARAMN6                => p_task_activity_rec.new_resource_id, --l_paramn6,--assignee_id
                                                          p_PARAMN7                => NULL,
                                                          p_PARAMN8                => NULL,
                                                          p_PARAMN9                => NULL,
                                                          p_PARAMN10               => Fnd_Global.USER_ID,
                                                          p_PARAMC1                => l_task_number,
                                                          p_PARAMC2                => p_task_activity_rec.new_owner_type_code,
                                                          p_PARAMC3                => p_task_activity_rec.new_owner_name,
                                                          p_PARAMC4                => p_task_activity_rec.new_resource_type_code, --resource_type_code sangiguptask
                                                          p_PARAMC5                => p_task_activity_rec.new_resource_name, --assignee_name sangiguptask
                                                          p_PARAMC6                => p_task_activity_rec.new_status, --task status
                                                          p_PARAMC7                => l_task_name, --task name sangiguptask
                                                          p_PARAMC8                => NULL,
                                                          p_PARAMC9                => NULL,
                                                          p_PARAMC10               => NULL, -- split from rep line number sangiguptask
                                                          p_PARAMD1                => l_planned_start_Date, -- planned start date
                                                          p_PARAMD2                => l_actual_start_Date,
                                                          p_PARAMD3                => l_actual_end_Date,
                                                          p_PARAMD4                => l_last_update_date,
                                                          p_PARAMD5                => NULL,
                                                          p_PARAMD6                => NULL,
                                                          p_PARAMD7                => NULL,
                                                          p_PARAMD8                => NULL,
                                                          p_PARAMD9                => NULL,
                                                          p_PARAMD10               => NULL,
                                                          p_ATTRIBUTE_CATEGORY     => NULL,
                                                          p_ATTRIBUTE1             => NULL,
                                                          p_ATTRIBUTE2             => NULL,
                                                          p_ATTRIBUTE3             => NULL,
                                                          p_ATTRIBUTE4             => NULL,
                                                          p_ATTRIBUTE5             => NULL,
                                                          p_ATTRIBUTE6             => NULL,
                                                          p_ATTRIBUTE7             => NULL,
                                                          p_ATTRIBUTE8             => NULL,
                                                          p_ATTRIBUTE9             => NULL,
                                                          p_ATTRIBUTE10            => NULL,
                                                          p_ATTRIBUTE11            => NULL,
                                                          p_ATTRIBUTE12            => NULL,
                                                          p_ATTRIBUTE13            => NULL,
                                                          p_ATTRIBUTE14            => NULL,
                                                          p_ATTRIBUTE15            => NULL,
                                                          p_LAST_UPDATE_LOGIN      => Fnd_Global.CONC_LOGIN_ID,
                                                          X_Return_Status          => x_return_status,
                                                          X_Msg_Count              => x_msg_count,
                                                          X_Msg_Data               => x_msg_data);
            --
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('After Task to Repair History : ' ||
                                        x_return_status);
            END IF;

            -- -------------------
            -- Api body ends here
            -- -------------------
            -- Standard check of p_commit.
            IF Fnd_Api.To_Boolean(p_commit)
            THEN
                COMMIT WORK;
            END IF;

            -- Standard call to get message count and IF count is  get message info.
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        END IF;
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Create_repair_task_hist;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Create_repair_task_hist;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Create_repair_task_hist;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END Create_repair_task_hist;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* procedure name: Update_repair_task_hist                                                                   */
    /* description   : procedure used to Update Repair Order history                                             */
    /*                 for task creation                                                                         */
    /* Called from   : Depot Repair Form to update to Repair history                                             */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 p_task_id             NUMBER      Required Task Id                                        */
    /*                 p_repair_line_id      NUMBER      Required Repair_line_id                                 */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE Update_repair_task_hist(p_api_version       IN NUMBER,
                                      p_init_msg_list     IN VARCHAR2 := Fnd_Api.g_true,
                                      p_commit            IN VARCHAR2 := Fnd_Api.g_false,
                                      p_validation_level  IN NUMBER := Fnd_Api.g_valid_level_full,
                                      p_task_activity_rec IN Csd_Process_Pvt.TASK_ACTIVITY_REC,
                                      x_return_status     OUT NOCOPY VARCHAR2,
                                      x_msg_count         OUT NOCOPY NUMBER,
                                      x_msg_data          OUT NOCOPY VARCHAR2) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'VALIDATE_AND_WRITE';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count          NUMBER;
        l_msg_data           VARCHAR2(2000);
        l_msg_index          NUMBER;
        l_return_status      VARCHAR2(1);
        l_repair_history_id  NUMBER;
        l_event_code         VARCHAR2(30);
        l_hist_ec            VARCHAR2(30);
        l_owner_type         VARCHAR2(240);
        l_owner              VARCHAR2(240);
        l_assignee_type      VARCHAR2(240);
        l_assignee_name      VARCHAR2(240);
        l_task_status        VARCHAR2(240);
        l_last_updated_by    NUMBER;
        l_assigned_by_id     NUMBER;
        l_task_number        VARCHAR2(240);
        l_task_name          VARCHAR2(240);
        l_planned_start_Date DATE;
        l_actual_start_Date  DATE;
        l_actual_end_Date    DATE;
        l_last_update_date   DATE;

        CURSOR c_task_hist(p_task_id NUMBER, p_repair_line_id NUMBER) IS
            SELECT hist.event_code,
                   hist.paramc2, -- owner type/assignee type(TAC)
                   hist.paramc3, -- tsk.owner name/assignee name (TAC)
                   hist.paramc4, -- assignee_type/previous assignee type (TAC)
                   hist.paramc5, -- tsk.assignee_name/prev task assignee name (TAC)
                   hist.paramc6, -- task status/null (TAC)
                   hist.paramn3, -- task owner id/assignee isd (TAC)
                   hist.paramn5, --status id/null (TAC)
                   hist.paramn6 -- tsk.assignee_id (TAC)
              FROM CSD_REPAIR_HISTORY hist
             WHERE hist.paramn1 = p_task_id
               AND hist.repair_line_id = p_repair_line_id
            --and hist.event_code             = 'TC'
             ORDER BY hist.repair_history_id DESC;

        CURSOR c_task(p_task_id NUMBER, p_repair_line_id NUMBER) IS
            SELECT

             tsk.last_updated_by, -- hist.paramn2

             tsk.assigned_by_id, -- hist.paramn4

             tsk.task_number, -- hist.paramc1
             tsk.task_name,

             tsk.planned_start_date, -- hist.paramd1
             tsk.actual_start_date, -- hist.paramd2
             tsk.actual_end_date, -- hist.paramd3
             tsk.last_update_date -- hist.paramd4
              FROM CSD_REPAIR_TASKS_V tsk
             WHERE tsk.source_object_type_code = 'DR'
               AND tsk.source_object_id = p_repair_line_id
               AND tsk.task_id = p_task_id;

    BEGIN
        -- --------------------------------
        -- Begin create repair task history
        -- --------------------------------
        -- Standard Start of API savepoint
        SAVEPOINT Update_repair_task_hist;
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------
        -- Api body starts
        -- ---------------
        -- if any of the values (Assignee, owner,status) have chnaged then proceed else get out
        IF (p_task_activity_rec.old_status_id <>
           p_task_activity_rec.new_status_id OR
           p_task_activity_rec.old_resource_id <>
           p_task_activity_rec.new_resource_id OR
           p_task_activity_rec.old_owner_id <>
           p_task_activity_rec.new_owner_id)
        THEN
            --fetch the cursor in local variables
            OPEN c_task(p_task_activity_rec.task_id,
                        p_task_activity_rec.repair_line_id);

            FETCH c_task
                INTO l_last_updated_by, -- last updated by
            l_assigned_by_id, -- assigned by id
            l_task_number, -- task number
            l_task_name, -- task name
            l_planned_start_Date, -- planned start date
            l_actual_start_Date, -- actual start date
            l_actual_end_Date, -- actual end date
            l_last_update_date; -- last updated date
            CLOSE c_task;
            -- find out the events that need to be logged.
            --If old owner name is not the same as the new owner name, log the event TOC
            IF (p_task_activity_rec.new_owner_id <>
               p_task_activity_rec.old_owner_id)
            THEN
                l_event_Code := 'TOC';
                --log the activity
                -- ------------------------------------------------------
                -- Internal Private API call to write to Repair History
                -- ------------------------------------------------------
                Csd_To_Form_Repair_History.Validate_And_Write(p_Api_Version_Number     => 1.0,
                                                              p_init_msg_list          => 'F',
                                                              p_commit                 => 'F',
                                                              p_validation_level       => NULL,
                                                              p_action_code            => 0,
                                                              px_REPAIR_HISTORY_ID     => l_repair_history_id,
                                                              p_OBJECT_VERSION_NUMBER  => NULL,
                                                              p_REQUEST_ID             => NULL,
                                                              p_PROGRAM_ID             => NULL,
                                                              p_PROGRAM_APPLICATION_ID => NULL,
                                                              p_PROGRAM_UPDATE_DATE    => NULL,
                                                              p_CREATED_BY             => Fnd_Global.USER_ID,
                                                              p_CREATION_DATE          => SYSDATE,
                                                              p_LAST_UPDATED_BY        => Fnd_Global.USER_ID,
                                                              p_LAST_UPDATE_DATE       => SYSDATE,
                                                              p_repair_line_id         => p_task_activity_rec.repair_line_id,
                                                              p_EVENT_CODE             => l_event_code,
                                                              p_EVENT_DATE             => SYSDATE,
                                                              p_QUANTITY               => NULL,
                                                              p_PARAMN1                => p_task_activity_rec.task_id, -- task_id
                                                              p_PARAMN2                => l_last_updated_by, -- last_updated_by
                                                              p_PARAMN3                => p_task_Activity_rec.new_owner_id, -- owner_id
                                                              p_PARAMN4                => l_assigned_by_id, -- assigned_by_id
                                                              p_PARAMN5                => p_task_Activity_rec.new_status_id, --l_paramn5, -- status_id
                                                              p_PARAMN6                => p_task_activity_rec.old_owner_id, -- assignee_id sangiguptask
                                                              p_PARAMN7                => NULL,
                                                              p_PARAMN8                => NULL,
                                                              p_PARAMN9                => NULL,
                                                              p_PARAMN10               => Fnd_Global.USER_ID,
                                                              p_PARAMC1                => l_task_number, -- l_paramc1,-- task number
                                                              p_PARAMC2                => p_task_activity_rec.new_owner_type_code, -- new owner type code
                                                              p_PARAMC3                => p_task_activity_rec.new_owner_name, -- task owner name
                                                              p_PARAMC4                => NULL, -- l_paramc4,-- asisgnee type
                                                              p_PARAMC5                => NULL, -- assignee name
                                                              p_PARAMC6                => p_task_activity_rec.new_status, -- task status
                                                              p_PARAMC7                => l_task_name,
                                                              p_PARAMC8                => p_task_activity_rec.old_owner_type_code, --prev owner type code
                                                              p_PARAMC9                => p_task_activity_Rec.old_owner_name, -- prev task owner name
                                                              p_PARAMC10               => NULL,
                                                              p_PARAMD1                => l_planned_start_Date,
                                                              p_PARAMD2                => l_actual_start_date,
                                                              p_PARAMD3                => l_actual_end_date,
                                                              p_PARAMD4                => l_last_update_Date,
                                                              p_PARAMD5                => NULL,
                                                              p_PARAMD6                => NULL,
                                                              p_PARAMD7                => NULL,
                                                              p_PARAMD8                => NULL,
                                                              p_PARAMD9                => NULL,
                                                              p_PARAMD10               => NULL,
                                                              p_ATTRIBUTE_CATEGORY     => NULL,
                                                              p_ATTRIBUTE1             => NULL,
                                                              p_ATTRIBUTE2             => NULL,
                                                              p_ATTRIBUTE3             => NULL,
                                                              p_ATTRIBUTE4             => NULL,
                                                              p_ATTRIBUTE5             => NULL,
                                                              p_ATTRIBUTE6             => NULL,
                                                              p_ATTRIBUTE7             => NULL,
                                                              p_ATTRIBUTE8             => NULL,
                                                              p_ATTRIBUTE9             => NULL,
                                                              p_ATTRIBUTE10            => NULL,
                                                              p_ATTRIBUTE11            => NULL,
                                                              p_ATTRIBUTE12            => NULL,
                                                              p_ATTRIBUTE13            => NULL,
                                                              p_ATTRIBUTE14            => NULL,
                                                              p_ATTRIBUTE15            => NULL,
                                                              p_LAST_UPDATE_LOGIN      => Fnd_Global.CONC_LOGIN_ID,
                                                              X_Return_Status          => x_return_status,
                                                              X_Msg_Count              => x_msg_count,
                                                              X_Msg_Data               => x_msg_data);

            END IF;
            --If old task status is not the same as the new task status , log the event TSC
            IF (p_task_activity_rec.new_status_id <>
               p_task_activity_rec.old_status_id)
            THEN
                l_event_Code := 'TSC';
                --log the activity
                -- ------------------------------------------------------
                -- Internal Private API call to write to Repair History
                -- ------------------------------------------------------
                Csd_To_Form_Repair_History.Validate_And_Write(p_Api_Version_Number     => 1.0,
                                                              p_init_msg_list          => 'F',
                                                              p_commit                 => 'F',
                                                              p_validation_level       => NULL,
                                                              p_action_code            => 0,
                                                              px_REPAIR_HISTORY_ID     => l_repair_history_id,
                                                              p_OBJECT_VERSION_NUMBER  => NULL,
                                                              p_REQUEST_ID             => NULL,
                                                              p_PROGRAM_ID             => NULL,
                                                              p_PROGRAM_APPLICATION_ID => NULL,
                                                              p_PROGRAM_UPDATE_DATE    => NULL,
                                                              p_CREATED_BY             => Fnd_Global.USER_ID,
                                                              p_CREATION_DATE          => SYSDATE,
                                                              p_LAST_UPDATED_BY        => Fnd_Global.USER_ID,
                                                              p_LAST_UPDATE_DATE       => SYSDATE,
                                                              p_repair_line_id         => p_task_activity_rec.repair_line_id,
                                                              p_EVENT_CODE             => l_event_code,
                                                              p_EVENT_DATE             => SYSDATE,
                                                              p_QUANTITY               => NULL,
                                                              p_PARAMN1                => p_task_activity_rec.task_id, -- task_id
                                                              p_PARAMN2                => l_last_updated_by, -- last_updated_by
                                                              p_PARAMN3                => p_task_Activity_rec.new_owner_id, -- owner_id
                                                              p_PARAMN4                => l_assigned_by_id, -- assigned_by_id
                                                              p_PARAMN5                => p_task_Activity_rec.new_status_id, --l_paramn5, -- status_id
                                                              p_PARAMN6                => p_task_activity_rec.old_status_id,
                                                              p_PARAMN7                => NULL,
                                                              p_PARAMN8                => NULL,
                                                              p_PARAMN9                => NULL,
                                                              p_PARAMN10               => Fnd_Global.USER_ID,
                                                              p_PARAMC1                => l_task_number, -- task number
                                                              p_PARAMC2                => p_task_activity_rec.new_owner_type_code, -- new owner type code
                                                              p_PARAMC3                => p_task_activity_rec.new_owner_name, -- task owner name
                                                              p_PARAMC4                => NULL, -- asisgnee type
                                                              p_PARAMC5                => NULL, -- assignee name
                                                              p_PARAMC6                => p_task_activity_rec.new_status, -- task status
                                                              p_PARAMC7                => l_task_name,
                                                              p_PARAMC8                => p_task_activity_rec.old_status, -- prev task status
                                                              p_PARAMC9                => NULL,
                                                              p_PARAMC10               => NULL,
                                                              p_PARAMD1                => l_planned_start_Date,
                                                              p_PARAMD2                => l_actual_start_date,
                                                              p_PARAMD3                => l_actual_end_date,
                                                              p_PARAMD4                => l_last_update_Date,
                                                              p_PARAMD5                => NULL,
                                                              p_PARAMD6                => NULL,
                                                              p_PARAMD7                => NULL,
                                                              p_PARAMD8                => NULL,
                                                              p_PARAMD9                => NULL,
                                                              p_PARAMD10               => NULL,
                                                              p_ATTRIBUTE_CATEGORY     => NULL,
                                                              p_ATTRIBUTE1             => NULL,
                                                              p_ATTRIBUTE2             => NULL,
                                                              p_ATTRIBUTE3             => NULL,
                                                              p_ATTRIBUTE4             => NULL,
                                                              p_ATTRIBUTE5             => NULL,
                                                              p_ATTRIBUTE6             => NULL,
                                                              p_ATTRIBUTE7             => NULL,
                                                              p_ATTRIBUTE8             => NULL,
                                                              p_ATTRIBUTE9             => NULL,
                                                              p_ATTRIBUTE10            => NULL,
                                                              p_ATTRIBUTE11            => NULL,
                                                              p_ATTRIBUTE12            => NULL,
                                                              p_ATTRIBUTE13            => NULL,
                                                              p_ATTRIBUTE14            => NULL,
                                                              p_ATTRIBUTE15            => NULL,
                                                              p_LAST_UPDATE_LOGIN      => Fnd_Global.CONC_LOGIN_ID,
                                                              X_Return_Status          => x_return_status,
                                                              X_Msg_Count              => x_msg_count,
                                                              X_Msg_Data               => x_msg_data);

            END IF;
            --If old task assignee id is not the same as the new task assignee id,log the event TSC
            IF (p_task_activity_rec.new_resource_id <>
               p_task_activity_rec.old_resource_id)
            THEN
                l_event_Code := 'TAC';
                --log the activity
                -- ------------------------------------------------------
                -- Internal Private API call to write to Repair History
                -- ------------------------------------------------------
                Csd_To_Form_Repair_History.Validate_And_Write(p_Api_Version_Number     => 1.0,
                                                              p_init_msg_list          => 'F',
                                                              p_commit                 => 'F',
                                                              p_validation_level       => NULL,
                                                              p_action_code            => 0,
                                                              px_REPAIR_HISTORY_ID     => l_repair_history_id,
                                                              p_OBJECT_VERSION_NUMBER  => NULL,
                                                              p_REQUEST_ID             => NULL,
                                                              p_PROGRAM_ID             => NULL,
                                                              p_PROGRAM_APPLICATION_ID => NULL,
                                                              p_PROGRAM_UPDATE_DATE    => NULL,
                                                              p_CREATED_BY             => Fnd_Global.USER_ID,
                                                              p_CREATION_DATE          => SYSDATE,
                                                              p_LAST_UPDATED_BY        => Fnd_Global.USER_ID,
                                                              p_LAST_UPDATE_DATE       => SYSDATE,
                                                              p_repair_line_id         => p_task_activity_rec.repair_line_id,
                                                              p_EVENT_CODE             => l_event_code,
                                                              p_EVENT_DATE             => SYSDATE,
                                                              p_QUANTITY               => NULL,
                                                              p_PARAMN1                => p_task_activity_rec.task_id, -- task_id
                                                              p_PARAMN2                => l_last_updated_by, -- last_updated_by
                                                              p_PARAMN3                => p_task_Activity_rec.new_resource_id, -- new assignee id
                                                              p_PARAMN4                => p_task_Activity_rec.old_resource_id, -- prev assignee id
                                                              p_PARAMN5                => NULL,
                                                              p_PARAMN6                => NULL,
                                                              p_PARAMN7                => NULL,
                                                              p_PARAMN8                => NULL,
                                                              p_PARAMN9                => NULL,
                                                              p_PARAMN10               => Fnd_Global.USER_ID,
                                                              p_PARAMC1                => l_task_number, -- task number
                                                              p_PARAMC2                => NULL,
                                                              p_PARAMC3                => NULL,
                                                              p_PARAMC4                => p_task_activity_rec.new_resource_type_code, -- new assignee type code
                                                              p_PARAMC5                => p_task_activity_rec.new_resource_name, -- new task assignee name
                                                              p_PARAMC6                => NULL,
                                                              p_PARAMC7                => l_task_name,
                                                              p_PARAMC8                => p_task_activity_rec.old_resource_type_code, -- old assignee type code
                                                              p_PARAMC9                => p_task_activity_rec.old_resource_name, -- old task assignee name
                                                              p_PARAMC10               => NULL,
                                                              p_PARAMD1                => NULL,
                                                              p_PARAMD2                => NULL,
                                                              p_PARAMD3                => NULL,
                                                              p_PARAMD4                => NULL,
                                                              p_PARAMD5                => NULL,
                                                              p_PARAMD6                => NULL,
                                                              p_PARAMD7                => NULL,
                                                              p_PARAMD8                => NULL,
                                                              p_PARAMD9                => NULL,
                                                              p_PARAMD10               => NULL,
                                                              p_ATTRIBUTE_CATEGORY     => NULL,
                                                              p_ATTRIBUTE1             => NULL,
                                                              p_ATTRIBUTE2             => NULL,
                                                              p_ATTRIBUTE3             => NULL,
                                                              p_ATTRIBUTE4             => NULL,
                                                              p_ATTRIBUTE5             => NULL,
                                                              p_ATTRIBUTE6             => NULL,
                                                              p_ATTRIBUTE7             => NULL,
                                                              p_ATTRIBUTE8             => NULL,
                                                              p_ATTRIBUTE9             => NULL,
                                                              p_ATTRIBUTE10            => NULL,
                                                              p_ATTRIBUTE11            => NULL,
                                                              p_ATTRIBUTE12            => NULL,
                                                              p_ATTRIBUTE13            => NULL,
                                                              p_ATTRIBUTE14            => NULL,
                                                              p_ATTRIBUTE15            => NULL,
                                                              p_LAST_UPDATE_LOGIN      => Fnd_Global.CONC_LOGIN_ID,
                                                              X_Return_Status          => x_return_status,
                                                              X_Msg_Count              => x_msg_count,
                                                              X_Msg_Data               => x_msg_data);

            END IF;

        END IF; -- most outer if
        --
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('After Task to Update Repair History : ' ||
                                    x_return_status);
        END IF;

        -- -------------------
        -- Api body ends here
        -- -------------------
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
        --END IF;
        -- ---------------------------------------------------------
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Update_repair_task_hist;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Update_repair_task_hist;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO Update_repair_task_hist;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END Update_repair_task_hist;

    /*----------------------------------------------------------------*/
    /* procedure name: Close_Status                                   */
    /* description   : procedure used to Close RO / Group RO and then */
    /*                 Close Service Request                          */
    /*----------------------------------------------------------------*/

    PROCEDURE Close_status(p_api_version      IN NUMBER,
                           p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                           p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                           p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                           p_incident_id      IN NUMBER,
                           p_repair_line_id   IN NUMBER,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'Status_Close';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count              NUMBER;
        l_msg_data               VARCHAR2(2000);
        l_msg_index              NUMBER;
        l_return_status          VARCHAR2(3);
        l_validate_flag          BOOLEAN;
        l_grp_rec                Csd_Repair_Groups_Pvt.REPAIR_ORDER_GROUP_REC;
        l_ro_rec                 Csd_Repairs_Pub.REPLN_Rec_Type;
        l_open_ro_cnt            NUMBER;
        l_repair_group_id        NUMBER;
        l_grp_count              NUMBER;
        l_status                 VARCHAR2(10) := 'CLOSED';
        l_ro_obj_version_number  NUMBER;
        l_grp_obj_version_number NUMBER;
        l_interaction_id         NUMBER;
        l_incident_id            NUMBER;
        l_inc_obj_version_number NUMBER;
        l_prof_value             VARCHAR2(1) := '';

        /* Fixed for bug#3416001
           Variable l_sr_status has been declared to get the
           status of service request which is equivalent of
           status 'Close' in local language.
        */
        l_sr_status VARCHAR2(30);

        CURSOR get_rep_group(p_incident_id IN NUMBER) IS
            SELECT crog.repair_group_id,
                   crt.repair_type_ref,
                   crog.group_txn_status
              FROM csd_repair_order_groups crog, csd_repair_types_vl crt
             WHERE crog.repair_type_id = crt.repair_type_id
               AND crog.incident_id = p_incident_id;

        CURSOR get_ro_order(p_repair_group_id IN NUMBER) IS
            SELECT repair_line_id
              FROM csd_repairs
             WHERE repair_group_id = p_repair_group_id;

    BEGIN
        --------------------------------------
        -- Standard Start of API savepoint
        --------------------------------------
        SAVEPOINT Close_Status;

        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;
        ------------------------------------------------------------
        -- Initialize message list if p_init_msg_list is set to TRUE.
        ------------------------------------------------------------
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        ---------------------------------------------
        -- Initialize API return status to success
        ---------------------------------------------
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        --------------------
        -- Api body starts
        --------------------
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info

            (p_pkg_name => G_PKG_NAME, p_api_name => l_api_name);
        END IF;

        l_prof_value := NVL(Fnd_Profile.value('CSD_CLOSE_SR'), 'N');
        --------------------------------------------
        -- Check whether status has to updated for
        -- a group / Repair Order
        --------------------------------------------

        IF (p_incident_id IS NOT NULL)
        THEN

            -- Validate the incident_id

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Incident Id =' || p_incident_id);
            END IF;

            l_validate_flag := Csd_Process_Util.validate_incident_id(p_incident_id);

            IF NOT (l_validate_flag)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('The Incident Id is invalid ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            -- For all the groups within SR

            FOR grp IN get_rep_group(p_incident_id)
            LOOP

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('grp.repair_type_ref  =' ||
                                            grp.repair_type_ref);
                END IF;

                IF grp.repair_type_ref IN ('AE', 'AL')
                THEN

                    IF grp.group_txn_status = 'OM_RECEIVED'
                    THEN

                        -- Update for all the Repair Orders within Group
                        FOR ro IN get_ro_order(grp.repair_group_id)
                        LOOP

                            BEGIN
                                SELECT object_version_number
                                  INTO l_ro_obj_version_number
                                  FROM csd_repairs
                                 WHERE repair_line_id = ro.repair_line_id;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    RAISE Fnd_Api.G_EXC_ERROR;
                            END;

                            l_ro_rec.object_version_number := l_ro_obj_version_number;
                            l_ro_rec.status                := 'C';

                            IF (g_debug > 0)
                            THEN
                                Csd_Gen_Utility_Pvt.ADD('Update Repair Line Id =' ||
                                                        ro.repair_line_id);
                            END IF;

                            Csd_Repairs_Pub.Update_Repair_Order(P_Api_Version_Number => 1.0,
                                                                P_Init_Msg_List      => 'T',
                                                                P_Commit             => 'F',
                                                                p_validation_level   => 0,
                                                                p_REPAIR_LINE_ID     => ro.repair_line_id,
                                                                P_REPLN_Rec          => l_ro_rec,
                                                                X_Return_Status      => l_return_status,
                                                                X_Msg_Count          => l_msg_count,
                                                                X_Msg_Data           => l_msg_data);

                            IF (l_return_status <> 'S')
                            THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_API_RO_STAT_UPD_FAIL');
                                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                                      ro.repair_line_id);
                                Fnd_Msg_Pub.ADD;
                                RAISE Fnd_Api.G_EXC_ERROR;
                            END IF;

                        END LOOP;

                        BEGIN
                            SELECT object_version_number
                              INTO l_grp_obj_version_number
                              FROM csd_repair_order_groups
                             WHERE repair_group_id = grp.repair_group_id;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RAISE Fnd_Api.G_EXC_ERROR;
                        END;

                        l_grp_rec.object_version_number := l_grp_obj_version_number;
                        l_grp_rec.group_txn_status      := 'CLOSED';
                        l_grp_rec.repair_group_id       := grp.repair_group_id;

                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('Update Repair Group Id =' ||
                                                    grp.repair_group_id);
                        END IF;

                        -- Update Group
                        Csd_Repair_Groups_Pvt.UPDATE_REPAIR_GROUPS(p_api_version            => 1.0,
                                                                   p_commit                 => 'F',
                                                                   p_init_msg_list          => 'T',
                                                                   p_validation_level       => 0,
                                                                   x_repair_order_group_rec => l_grp_rec,
                                                                   x_return_status          => l_return_status,
                                                                   x_msg_count              => l_msg_count,
                                                                   x_msg_data               => l_msg_data);

                        IF (l_return_status <> 'S')
                        THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_API_GRP_STAT_UPD_FAIL');
                            Fnd_Message.SET_TOKEN('REPAIR_GROUP_ID',
                                                  grp.repair_group_id);
                            Fnd_Msg_Pub.ADD;
                            RAISE Fnd_Api.G_EXC_ERROR;
                        END IF;

                    END IF;

                ELSIF grp.repair_type_ref IN ('RR', 'E', 'WR')
                THEN

                    IF grp.group_txn_status = 'OM_SHIPPED'
                    THEN

                        -- Update all the repair orders within group

                        FOR ro IN get_ro_order(grp.repair_group_id)
                        LOOP

                            BEGIN
                                SELECT object_version_number
                                  INTO l_ro_obj_version_number
                                  FROM csd_repairs
                                 WHERE repair_line_id = ro.repair_line_id;
                            EXCEPTION
                                WHEN OTHERS THEN
                                    RAISE Fnd_Api.G_EXC_ERROR;
                            END;

                            l_ro_rec.object_version_number := l_ro_obj_version_number;
                            l_ro_rec.status                := 'C';

                            IF (g_debug > 0)
                            THEN
                                Csd_Gen_Utility_Pvt.ADD('Update Repair Line Id =' ||
                                                        ro.repair_line_id);
                            END IF;

                            Csd_Repairs_Pub.Update_Repair_Order(P_Api_Version_Number => 1.0,
                                                                P_Init_Msg_List      => 'T',
                                                                P_Commit             => 'F',
                                                                p_validation_level   => 0,
                                                                p_REPAIR_LINE_ID     => ro.repair_line_id,
                                                                P_REPLN_Rec          => l_ro_rec,
                                                                X_Return_Status      => l_return_status,
                                                                X_Msg_Count          => l_msg_count,
                                                                X_Msg_Data           => l_msg_data);

                            IF (l_return_status <> 'S')
                            THEN
                                Fnd_Message.SET_NAME('CSD',
                                                     'CSD_API_RO_STAT_UPD_FAIL');
                                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID',
                                                      ro.repair_line_id);
                                Fnd_Msg_Pub.ADD;
                                RAISE Fnd_Api.G_EXC_ERROR;
                            END IF;

                        END LOOP;

                        BEGIN
                            SELECT object_version_number
                              INTO l_grp_obj_version_number
                              FROM csd_repair_order_groups
                             WHERE repair_group_id = grp.repair_group_id;
                        EXCEPTION
                            WHEN OTHERS THEN
                                RAISE Fnd_Api.G_EXC_ERROR;
                        END;

                        l_grp_rec.object_version_number := l_grp_obj_version_number;
                        l_grp_rec.group_txn_status      := 'CLOSED';
                        l_grp_rec.repair_group_id       := grp.repair_group_id;

                        IF (g_debug > 0)
                        THEN
                            Csd_Gen_Utility_Pvt.ADD('Update Repair Group Id =' ||
                                                    grp.repair_group_id);
                        END IF;

                        -- Update the Group

                        Csd_Repair_Groups_Pvt.UPDATE_REPAIR_GROUPS(p_api_version            => 1.0,
                                                                   p_commit                 => 'F',
                                                                   p_init_msg_list          => 'T',
                                                                   p_validation_level       => 0,
                                                                   x_repair_order_group_rec => l_grp_rec,
                                                                   x_return_status          => l_return_status,
                                                                   x_msg_count              => l_msg_count,
                                                                   x_msg_data               => l_msg_data);

                        IF (l_return_status <> 'S')
                        THEN
                            Fnd_Message.SET_NAME('CSD',
                                                 'CSD_API_GRP_STAT_UPD_FAIL');
                            Fnd_Message.SET_TOKEN('REPAIR_GROUP_ID',
                                                  grp.repair_group_id);
                            Fnd_Msg_Pub.ADD;
                            RAISE Fnd_Api.G_EXC_ERROR;
                        END IF;

                    END IF; -- grp_txn_status

                END IF; -- rep_typ_ref

            END LOOP; -- end of all groups

            BEGIN

                SELECT COUNT(*)
                  INTO l_open_ro_cnt
                  FROM csd_repairs
                 WHERE incident_id = p_incident_id
                   AND status <> 'C';

            EXCEPTION
                WHEN OTHERS THEN
                    l_open_ro_cnt := -1;
            END;

            IF l_open_ro_cnt = 0
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Update Incident Id =' ||
                                            p_incident_id);
                END IF;

                BEGIN
                    SELECT object_version_number
                      INTO l_inc_obj_version_number
                      FROM cs_incidents_all_b
                     WHERE incident_id = p_incident_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_inc_obj_version_number := -1;
                END;

                -- swai bug fix 3376564
                -- (1) Close the SR using the seeded 'Closed' status if it is valid
                -- (2) If the seeded status is not valid, then close the SR using the
                --     first valid closed status.
                BEGIN
                    SELECT name
                      INTO l_sr_status
                      FROM cs_incident_statuses_vl
                     WHERE incident_subtype = 'INC'
                       AND CLOSE_FLAG = 'Y'
                       AND TRUNC(SYSDATE) BETWEEN
                           TRUNC(NVL(start_date_active, SYSDATE)) AND
                           TRUNC(NVL(end_date_active, SYSDATE))
                       AND status_code = 'CLOSED';
                EXCEPTION
                    WHEN OTHERS THEN
                        l_sr_status := NULL;
                END;

                IF (l_sr_status IS NULL)
                THEN
                    /* Fixed for bug#3416001
                       Following query has been added to get the
                       status of service request which is equivalent of
                       status 'Close' in local language.
                    */
                    SELECT name
                      INTO l_sr_status
                      FROM cs_incident_statuses_vl
                     WHERE incident_subtype = 'INC'
                       AND CLOSE_FLAG = 'Y'
                       AND TRUNC(SYSDATE) BETWEEN
                           TRUNC(NVL(start_date_active, SYSDATE)) AND
                           TRUNC(NVL(end_date_active, SYSDATE))
                       AND ROWNUM < 2;
                END IF;

                IF l_prof_value = 'Y'
                THEN
                    -- Update the Service Request
                    Cs_Servicerequest_Pub.Update_Status(p_api_version           => 2.0,
                                                        p_init_msg_list         => 'T',
                                                        p_commit                => 'F',
                                                        x_return_status         => l_return_status,
                                                        x_msg_count             => l_msg_count,
                                                        x_msg_data              => l_msg_data,
                                                        p_resp_appl_id          => Fnd_Global.RESP_APPL_ID,
                                                        p_resp_id               => Fnd_Global.RESP_ID,
                                                        p_user_id               => Fnd_Global.USER_ID,
                                                        p_login_id              => Fnd_Global.LOGIN_ID,
                                                        p_request_id            => p_incident_id,
                                                        p_request_number        => NULL,
                                                        p_object_version_number => l_inc_obj_version_number,
                                                        p_status_id             => NULL,
                                                        --            p_status            => 'CLOSED',
                                                        /* Fixed for bug#3416001
                                                                       Hardcoding for parameter p_status has been removed.
                                                                    */
                                                        p_status              => l_sr_status,
                                                        p_closed_date         => SYSDATE,
                                                        p_audit_comments      => NULL,
                                                        p_called_by_workflow  => 'F',
                                                        p_workflow_process_id => NULL,
                                                        p_comments            => NULL,
                                                        p_public_comment_flag => 'F',
                                                        x_interaction_id      => l_interaction_id);

                    IF (l_return_status <> 'S')
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_API_SR_STAT_UPD_FAIL');
                        Fnd_Message.SET_TOKEN('INCIDENT_ID', p_incident_id);
                        Fnd_Msg_Pub.ADD;
                        RAISE Fnd_Api.G_EXC_ERROR;
                    END IF;

                END IF;

            END IF;

        ELSIF (p_repair_line_id IS NOT NULL)
        THEN

            -- Validate the repair_line_id

            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Update Repair Line ID =' ||
                                        p_repair_line_id);
            END IF;

            l_validate_flag := Csd_Process_Util.validate_rep_line_id(p_repair_line_id);

            IF NOT (l_validate_flag)
            THEN
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Repair Line Id is invalid ');
                END IF;

                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            BEGIN
                SELECT object_version_number
                  INTO l_ro_obj_version_number
                  FROM csd_repairs
                 WHERE repair_line_id = p_repair_line_id;
            EXCEPTION
                WHEN OTHERS THEN
                    RAISE Fnd_Api.G_EXC_ERROR;
            END;

            l_ro_rec.object_version_number := l_ro_obj_version_number;
            l_ro_rec.status                := 'C';

            -- Update the Repair Order
            Csd_Repairs_Pub.Update_Repair_Order(P_Api_Version_Number => 1.0,
                                                P_Init_Msg_List      => 'T',
                                                P_Commit             => 'F',
                                                p_validation_level   => 0,
                                                p_REPAIR_LINE_ID     => p_repair_line_id,
                                                P_REPLN_Rec          => l_ro_rec,
                                                X_Return_Status      => l_return_status,
                                                X_Msg_Count          => l_msg_count,
                                                X_Msg_Data           => l_msg_data);

            IF (l_return_status <> 'S')
            THEN
                Fnd_Message.SET_NAME('CSD', 'CSD_API_RO_STAT_UPD_FAIL');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', p_repair_line_id);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;

            BEGIN

                SELECT repair_group_id, incident_id
                  INTO l_repair_group_id, l_incident_id
                  FROM csd_repairs
                 WHERE repair_line_id = p_repair_line_id;

                IF (l_repair_group_id IS NOT NULL)
                THEN
                    SELECT COUNT(*)
                      INTO l_grp_count
                      FROM csd_repairs
                     WHERE status = 'C'
                       AND repair_group_id = l_repair_group_id;
                END IF;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    l_grp_count := -1;
            END;

            -- Update the Group only if its exists

            IF (l_grp_count = 0 AND l_repair_group_id IS NOT NULL)
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Update Repair Group Id =' ||
                                            l_repair_group_id);
                END IF;

                BEGIN
                    SELECT object_version_number
                      INTO l_grp_obj_version_number
                      FROM csd_repair_order_groups
                     WHERE repair_group_id = l_repair_group_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        RAISE Fnd_Api.G_EXC_ERROR;
                END;

                l_grp_rec.object_version_number := l_grp_obj_version_number;
                l_grp_rec.group_txn_status      := 'CLOSED';
                l_grp_rec.repair_group_id       := l_repair_group_id;

                Csd_Repair_Groups_Pvt.UPDATE_REPAIR_GROUPS(p_api_version            => 1.0,
                                                           p_commit                 => 'F',
                                                           p_init_msg_list          => 'T',
                                                           p_validation_level       => 0,
                                                           x_repair_order_group_rec => l_grp_rec,
                                                           x_return_status          => l_return_status,
                                                           x_msg_count              => l_msg_count,
                                                           x_msg_data               => l_msg_data);

                IF (l_return_status <> 'S')
                THEN
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_API_GRP_STAT_UPD_FAIL');
                    Fnd_Message.SET_TOKEN('REPAIR_GROUP_ID',
                                          l_repair_group_id);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;

            END IF;

            BEGIN

                SELECT COUNT(*)
                  INTO l_open_ro_cnt
                  FROM csd_repairs
                 WHERE incident_id = l_incident_id
                   AND status <> 'C';

            EXCEPTION
                WHEN OTHERS THEN
                    l_open_ro_cnt := -1;
            END;

            IF l_open_ro_cnt = 0
            THEN

                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('Update Service Request = ' ||
                                            l_incident_id);
                END IF;

                -- Update the Service Request

                BEGIN
                    SELECT object_version_number
                      INTO l_inc_obj_version_number
                      FROM cs_incidents_all_b
                     WHERE incident_id = l_incident_id;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_inc_obj_version_number := -1;
                END;

                -- swai bug fix 3376564
                -- (1) Close the SR using the seeded 'Closed' status if it is valid
                -- (2) If the seeded status is not valid, then close the SR using the
                --     first valid closed status.
                BEGIN
                    SELECT name
                      INTO l_sr_status
                      FROM cs_incident_statuses_vl
                     WHERE incident_subtype = 'INC'
                       AND CLOSE_FLAG = 'Y'
                       AND TRUNC(SYSDATE) BETWEEN
                           TRUNC(NVL(start_date_active, SYSDATE)) AND
                           TRUNC(NVL(end_date_active, SYSDATE))
                       AND status_code = 'CLOSED';
                EXCEPTION
                    WHEN OTHERS THEN
                        l_sr_status := NULL;
                END;

                IF (l_sr_status IS NULL)
                THEN
                    /* Fixed for bug#3416001
                     Following query has been added to get the
                     status of service request which is equivalent of
                     status 'Close' in local language.
                    */
                    SELECT name
                      INTO l_sr_status
                      FROM cs_incident_statuses_vl
                     WHERE incident_subtype = 'INC'
                       AND CLOSE_FLAG = 'Y'
                       AND TRUNC(SYSDATE) BETWEEN
                           TRUNC(NVL(start_date_active, SYSDATE)) AND
                           TRUNC(NVL(end_date_active, SYSDATE))
                       AND ROWNUM < 2;
                END IF;

                IF l_prof_value = 'Y'
                THEN
                    -- Update the Service Request
                    Cs_Servicerequest_Pub.Update_Status(p_api_version           => 2.0,
                                                        p_init_msg_list         => 'T',
                                                        p_commit                => 'F',
                                                        x_return_status         => l_return_status,
                                                        x_msg_count             => l_msg_count,
                                                        x_msg_data              => l_msg_data,
                                                        p_resp_appl_id          => Fnd_Global.RESP_APPL_ID,
                                                        p_resp_id               => Fnd_Global.RESP_ID,
                                                        p_user_id               => Fnd_Global.USER_ID,
                                                        p_login_id              => Fnd_Global.LOGIN_ID,
                                                        p_request_id            => l_incident_id,
                                                        p_request_number        => NULL,
                                                        p_object_version_number => l_inc_obj_version_number,
                                                        p_status_id             => NULL,
                                                        --            p_status            => 'CLOSED',
                                                        /* Fixed for bug#3416001
                                                                       Hardcoding for parameter p_status has been removed.
                                                                    */
                                                        p_status              => l_sr_status,
                                                        p_closed_date         => SYSDATE,
                                                        p_audit_comments      => NULL,
                                                        p_called_by_workflow  => 'F',
                                                        p_workflow_process_id => NULL,
                                                        p_comments            => NULL,
                                                        p_public_comment_flag => 'F',
                                                        x_interaction_id      => l_interaction_id);

                    IF (l_return_status <> 'S')
                    THEN
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_API_SR_STAT_UPD_FAIL');
                        Fnd_Message.SET_TOKEN('INCIDENT_ID', l_incident_id);
                        Fnd_Msg_Pub.ADD;
                        --Bug fix for 3555256 Begin
                        --RAISE FND_API.G_EXC_ERROR;
                        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                                  p_data  => x_msg_data);
                        --Bug fix for 3555256 End

                    END IF;
                END IF;
            END IF;

        END IF;

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO Close_Status;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO status_close;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO status_close;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END Close_Status;

    /*---------------------------------------------------------------*/
    /* procedure name: Check_Service_Request                         */
    /* Description:  procedure used to find if there are unasigned   */
    /*               RMA/SO lines for the given service request      */
    /* Parameters    x_link_mode  determines the way the screen flow */
    /*               will happen. The valid values are               */
    /*               1: Only unlinked RMA's exist                    */
    /*               2: Both unlinked RMA's and unlinked SO's exist  */
    /*               3: Only unlinked SO's with atleast 1 repair     */
    /*                   for the service request                     */
    /*               4: Only unlinked SO without any repair order    */
    /*                   for the service request                     */
    /*               5: No unlinked RMA or SO                        */
    /*---------------------------------------------------------------*/

    PROCEDURE Check_Service_Request(p_api_version      IN NUMBER,
                                    p_commit           IN VARCHAR2 := Fnd_Api.g_false,
                                    p_init_msg_list    IN VARCHAR2 := Fnd_Api.g_false,
                                    p_validation_level IN NUMBER := Fnd_Api.g_valid_level_full,
                                    p_incident_id      IN NUMBER,
                                    x_link_mode        OUT NOCOPY NUMBER,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_msg_count        OUT NOCOPY NUMBER,
                                    x_msg_data         OUT NOCOPY VARCHAR2) IS
        l_api_name CONSTANT VARCHAR2(30) := 'Check_Service_Request';
        l_rma_count NUMBER;
        l_so_count  NUMBER;
        l_ro_count  NUMBER;

        --Cursor for selecting count of RMA/SO
        CURSOR RMA_SO_CUR(p_incident_Id NUMBER) IS
            SELECT Line_Category_code, COUNT(*) line_count
              FROM CSD_ESTIMATE_DETAILS_EXT_V
             WHERE INCIDENT_ID = p_incident_Id
               AND Line_Category_Code IN ('RETURN', 'ORDER')
             GROUP BY Line_Category_Code;

        --Cursor to get the count of repair orders for the given SR
        CURSOR RO_CUR(p_incident_Id NUMBER) IS
            SELECT COUNT(*) ro_count
              FROM CSD_REPAIRS
             WHERE INCIDENT_ID = p_incident_Id;

    BEGIN

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('In Check_Service_Request API');
        END IF;

        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Initialize the count vars
        l_rma_count := 0;
        l_so_count  := 0;
        --Get the count for RMA and SO
        FOR rma_so_rec IN RMA_SO_CUR(p_incident_Id)
        LOOP
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Unlinked RMA/SO found ');
                Csd_Gen_Utility_Pvt.ADD('Category[' ||
                                        rma_so_Rec.Line_Category_Code || ']');
                Csd_Gen_Utility_Pvt.ADD('count[' || rma_so_Rec.line_Count || ']');
            END IF;

            IF (rma_so_Rec.Line_Category_Code = 'RETURN')
            THEN
                l_rma_Count := rma_so_Rec.line_Count;
            END IF;
            IF (rma_so_Rec.Line_Category_Code = 'ORDER')
            THEN
                l_so_Count := rma_so_Rec.line_Count;
            END IF;
        END LOOP;

        --Determine the mode
        IF (l_rma_count > 0 AND l_so_Count > 0)
        THEN
            x_link_mode := 2;
        ELSIF (l_rma_count = 0 AND l_so_count = 0)
        THEN
            x_link_mode := 5;
        ELSIF (l_so_count = 0 AND l_rma_count > 0)
        THEN
            x_link_mode := 1;
        ELSIF (l_rma_count = 0 AND l_so_count > 0)
        THEN
            -- get the count of repair orders and
            -- set the mode to 3 if there are repair orders
            -- or to 4 if there are no reapair orders.
            l_ro_count := 0;
            OPEN RO_CUR(p_incident_Id);
            FETCH RO_CUR
                INTO l_ro_count;
            CLOSE RO_CUR;

            IF (l_ro_Count > 0)
            THEN
                x_link_mode := 3;
            ELSE
                x_link_mode := 4;
            END IF;

        END IF;

        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Leaving checkService_Request link mode[' ||
                                    TO_CHAR(x_link_mode) || ']');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END Check_Service_Request;

    /*---------------------------------------------------------------*/
    /* procedure name: Update_Line_Txn_Source                        */
    /* Description:  procedure used to update the source_code and    */
    /*               source_id of the line transaction               */
    /*---------------------------------------------------------------*/
    PROCEDURE Update_Line_Txn_Source(p_api_version             IN NUMBER,
                                     p_commit                  IN VARCHAR2,
                                     p_init_msg_list           IN VARCHAR2,
                                     p_validation_level        IN NUMBER,
                                     p_incident_id             IN NUMBER,
                                     p_estimate_detail_line_id IN NUMBER,
                                     p_repair_line_id          IN NUMBER,
                                     x_return_status           OUT NOCOPY VARCHAR2,
                                     x_msg_count               OUT NOCOPY NUMBER,
                                     x_msg_data                OUT NOCOPY VARCHAR2) IS
    BEGIN

        UPDATE CS_ESTIMATE_DETAILS
           SET SOURCE_CODE = 'DR', SOURCE_ID = p_repair_line_id
         WHERE INCIDENT_ID = p_incident_id
           AND ESTIMATE_DETAIL_ID = p_estimate_detail_line_id;

    END Update_Line_Txn_Source;

    /*---------------------------------------------------------------------------------*/
    /* procedure name: Update_iro_product_txn                                          */
    /* Description:  procedure used to update the product transaction                  */
    /*               table and process pick release and shipping                       */
    /*               transactions for internal ROs.                                    */
    /*   p_api_version         Standard in parameter                                   */
    /*   p_commit              Standard in parameter                                   */
    /*   p_init_msg_list       Standard in parameter                                   */
    /*   p_validation_level    Standard in parameter                                   */
    /*   x_return_status       Standard Out parameter                                  */
    /*   x_msg_count           Standard in parameter                                   */
    /*   x_msg_data            Standard in parameter ,                                 */
    /*   x_product_txn_rec     in out record variable of type                          */
    /*                         csd_process_pvt.product_txn_rec ) ;                     */
    /*---------------------------------------------------------------------------------*/
    PROCEDURE update_iro_product_txn(p_api_version      IN NUMBER,
                                     p_commit           IN VARCHAR2,
                                     p_init_msg_list    IN VARCHAR2,
                                     p_validation_level IN NUMBER,
                                     x_product_txn_rec  IN OUT nocopy Csd_Process_Pvt.product_txn_rec,
                                     x_return_status    OUT nocopy VARCHAR2,
                                     x_msg_count        OUT nocopy NUMBER,
                                     x_msg_data         OUT nocopy VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'update_iro_product_txn';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count               NUMBER;
        l_msg_data                VARCHAR2(2000);
        l_msg_index               NUMBER;
        l_check                   VARCHAR2(1);
        l_order_rec               Csd_Process_Pvt.om_interface_rec;
        l_est_detail_id           NUMBER := NULL;
        l_incident_id             NUMBER := NULL;
        l_party_id                NUMBER := NULL;
        l_account_id              NUMBER := NULL;
        l_order_header_id         NUMBER := NULL;
        l_released_status         VARCHAR2(1) := '';
        l_picking_rule_id         NUMBER := NULL;
        l_repair_line_id          NUMBER := NULL;
        l_curr_submit_order_flag  VARCHAR2(1) := '';
        l_curr_book_order_flag    VARCHAR2(1) := '';
        l_curr_release_order_flag VARCHAR2(1) := '';
        l_curr_ship_order_flag    VARCHAR2(1) := '';
        l_booked_flag             VARCHAR2(1) := '';
        l_allow_ship              VARCHAR2(1) := '';
        l_object_version_num      NUMBER := NULL;
        l_ship_from_org_id        NUMBER := NULL;
        l_order_line_id           NUMBER := NULL;
        l_bus_process_id          NUMBER := NULL;
        l_unit_selling_price      NUMBER := NULL;
        l_serial_flag             BOOLEAN := FALSE;
        l_order_category_code     VARCHAR2(30);
        l_orig_src_reference      VARCHAR2(30);
        l_orig_src_header_id      NUMBER;
        l_orig_src_line_id        NUMBER;
        l_orig_po_num             VARCHAR2(50);

        -- travi fix
        l_repair_mode     VARCHAR2(30) := NULL;
        l_count_est       NUMBER := 0;
        l_count_iface_est NUMBER := 0;
        l_count_task      NUMBER := 0;
        l_count_wip       NUMBER := 0;

        C_Yes  CONSTANT VARCHAR2(1) := 'Y';
        C_No   CONSTANT VARCHAR2(1) := 'N';
        C_Zero CONSTANT NUMBER := 0;

        -- define variables to define fnd_log debug levels
        l_debug_level NUMBER := Fnd_Log.g_current_runtime_level;
        -- examples : 1- copying buffer x to y : low level detailed messages
        l_statement_level NUMBER := Fnd_Log.level_statement;
        -- examples : 2- key progress events : starting business transactions
        l_procedure_level NUMBER := Fnd_Log.level_procedure;
        -- examples : 3- event  : calling an api, key progress events
        l_event_level NUMBER := Fnd_Log.level_event;
        -- examples : 4- exception  internal software failure condition
        l_exception_level NUMBER := Fnd_Log.level_exception;
        -- examples : 5- error  end user erros
        l_error_level NUMBER := Fnd_Log.level_error;
        l_module_name VARCHAR2(240) := 'csd.plsql.csd_process_pvt.update_iro_product_txn';

        -- a variable whose value tells us whether order header can be pick released or not.
        l_order_to_be_pickreleased VARCHAR2(1) := C_NO;
        -- a variable whose value tells us whether order header can be shipped or not.
        l_order_to_be_shipped VARCHAR2(1) := C_No;

        -- constants to define delivery line release statuses
        c_ready_for_release    CONSTANT VARCHAR2(1) := 'R';
        c_backordered          CONSTANT VARCHAR2(1) := 'B';
        c_staged_pickconfirmed CONSTANT VARCHAR2(1) := 'Y';
        c_shipped              CONSTANT VARCHAR2(1) := 'C';
        c_cancelled            CONSTANT VARCHAR2(1) := 'D';
        c_release_to_warehouse CONSTANT VARCHAR2(1) := 'S';
        ----- End of definition of release statuses

        -- Define variable for action type values
        C_Action_Type_Move_Out CONSTANT VARCHAR2(30) := 'MOVE_OUT';
        C_Action_Type_Move_In  CONSTANT VARCHAR2(30) := 'MOVE_IN';

        -- Define varialbes for Action variable in  process_sales_order API
        C_Action_Pick_Release CONSTANT VARCHAR2(30) := 'PICK-RELEASE';
        C_Action_Ship         CONSTANT VARCHAR2(30) := 'SHIP';

        -- Define constants to hold product txn status values
        C_Status_Released CONSTANT VARCHAR2(30) := 'RELEASED';
        C_Status_Shipped  CONSTANT VARCHAR2(30) := 'SHIPPED';

        release_order_excep EXCEPTION;
        ship_order_excep EXCEPTION;

        CURSOR sr_rec(p_incident_id IN NUMBER) IS
            SELECT customer_id, account_id
              FROM cs_incidents_all_b
             WHERE incident_id = p_incident_id;

        CURSOR prod_txn(p_prod_txn_id IN NUMBER) IS
            SELECT estimate_detail_id,
                   repair_line_id,
                   interface_to_om_flag,
                   book_sales_order_flag,
                   release_sales_order_flag,
                   ship_sales_order_flag,
                   object_version_number
              FROM csd_product_transactions
             WHERE product_transaction_id = p_prod_txn_id;

        CURSOR released_lines_cur(p_order_header_id IN NUMBER, p_Order_Line_id IN NUMBER) IS
            SELECT source_header_id, source_line_id, released_status
              FROM wsh_delivery_details
             WHERE source_header_id = p_order_header_id
               AND Source_line_id = p_Order_line_id
	       AND SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
               AND released_status = C_Staged_PickConfirmed;

        CURSOR shipped_lines_cur(p_order_header_id IN NUMBER, p_Order_Line_Id IN NUMBER) IS
            SELECT source_header_id, source_line_id, released_status
              FROM wsh_delivery_details
             WHERE source_header_id = p_order_header_id
               AND Source_line_id = p_Order_line_id
	       AND SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
               AND released_status = C_Shipped;

    BEGIN
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level, l_module_name, 'begin');
        END IF;
        -- standard start of api savepoint
        SAVEPOINT update_iro_product_txn;
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility');
        END IF;
        -- standard call to check for call compatibility.
        IF NOT Fnd_Api.compatible_api_call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           g_pkg_name)
        THEN
            IF l_exception_level >= l_debug_level
            THEN
                Fnd_Log.string(l_exception_level,
                               l_module_name,
                               'checking api compatibility, was unsuccessful');
            END IF;
            RAISE Fnd_Api.g_exc_unexpected_error;
        END IF;
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility, was successful');
        END IF;

        -- initialize message list if p_init_msg_list is set to true.
        IF Fnd_Api.to_boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- initialize api return status to success
        x_return_status := Fnd_Api.g_ret_sts_success;

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Product Transaction Record Values:');
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Product Transaction Id   :' ||
                           x_product_txn_rec.Product_Transaction_Id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Repair_line_id           :' ||
                           x_product_txn_rec.repair_line_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Action_type              :' ||
                           x_product_txn_rec.action_type);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Action_code              :' ||
                           x_product_txn_rec.action_code);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Incident_id              :' ||
                           x_product_txn_rec.incident_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'line_type_id             :' ||
                           x_product_txn_rec.line_type_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Order_number             :' ||
                           x_product_txn_rec.order_number);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Status                   :' ||
                           x_product_txn_rec.status);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Currency_code            :' ||
                           x_product_txn_rec.currency_code);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Unit_of_measure_code     :' ||
                           x_product_txn_rec.unit_of_measure_code);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Inventory_item_id        :' ||
                           x_product_txn_rec.inventory_item_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Revision                 :' ||
                           x_product_txn_rec.revision);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Quantity                 :' ||
                           x_product_txn_rec.quantity);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Price_list_id            :' ||
                           x_product_txn_rec.price_list_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Source Organization_id   :' ||
                           x_product_txn_rec.organization_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Interface_to_om_flag     :' ||
                           x_product_txn_rec.interface_to_om_flag);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Book_sales_order_flag    :' ||
                           x_product_txn_rec.book_sales_order_flag);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Release_sales_order_flag :' ||
                           x_product_txn_rec.release_sales_order_flag);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Ship_sales_order_flag    :' ||
                           x_product_txn_rec.ship_sales_order_flag);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Process_txn_flag         :' ||
                           x_product_txn_rec.process_txn_flag);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Object_version_number    :' ||
                           x_product_txn_rec.object_version_number);
        END IF;

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'product txn id is:' ||
                           x_product_txn_rec.product_transaction_id);
        END IF;

        -- check the required parameter
        Csd_Process_Util.check_reqd_param(p_param_value => x_product_txn_rec.product_transaction_id,
                                          p_param_name  => 'product_transaction_id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'product txn id is valid');
        END IF;

        -- validate the prod_txn_id if it exists in csd_product_transactions
        IF NOT
            (Csd_Process_Util.validate_prod_txn_id(p_prod_txn_id => x_product_txn_rec.product_transaction_id))
        THEN
            IF l_exception_level >= l_debug_level
            THEN
                Fnd_Log.string(l_exception_level,
                               l_module_name || '.check_in_parameters',
                               'product txn id is not valid ');
            END IF;
            RAISE Fnd_Api.g_exc_error;
        END IF;
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'product txn id is valid ');
        END IF;

        -- validate the prod_txn_status
        IF NVL(x_product_txn_rec.prod_txn_status, Fnd_Api.g_miss_char) <>
           Fnd_Api.g_miss_char
        THEN
            BEGIN
                SELECT 'x'
                  INTO l_check
                  FROM fnd_lookups
                 WHERE lookup_type = 'CSD_PRODUCT_TXN_STATUS'
                   AND lookup_code = x_product_txn_rec.prod_txn_status;
                IF l_statement_level >= l_debug_level
                THEN
                    Fnd_Log.string(l_statement_level,
                                   l_module_name || '.check_in_parameters',
                                   'Product txn status is valid : ' ||
                                   x_product_txn_rec.prod_txn_status);
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.set_name('CSD', 'CSD_ERR_PROD_TXN_STATUS');
                    IF l_exception_level >= l_debug_level
                    THEN
                        Fnd_Log.string(l_exception_level,
                                       l_module_name ||
                                       '.check_in_parameters',
                                       'Product txn status is invalid : ' ||
                                       x_product_txn_rec.prod_txn_status);
                    END IF;
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.g_exc_error;
            END;
        END IF;

        IF NVL(x_product_txn_rec.action_type, Fnd_Api.g_miss_char) <>
           Fnd_Api.g_miss_char
        THEN
            -- validate the action type
            IF NOT
                (Csd_Process_Util.validate_action_type(p_action_type => x_product_txn_rec.action_type))
            THEN
                IF l_exception_level >= l_debug_level
                THEN
                    Fnd_Log.string(l_exception_level,
                                   l_module_name || '.check_in_parameters',
                                   'Action Type s invalid : ' ||
                                   x_product_txn_rec.Action_Type);
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;
        END IF;

        IF NVL(x_product_txn_rec.action_code, Fnd_Api.g_miss_char) <>
           Fnd_Api.g_miss_char
        THEN
            -- validate the action code
            IF NOT
                (Csd_Process_Util.validate_action_code(p_action_code => x_product_txn_rec.action_code))
            THEN
                IF l_exception_level >= l_debug_level
                THEN
                    Fnd_Log.string(l_exception_level,
                                   l_module_name || '.check_in_parameters',
                                   'Action Code is invalid : ' ||
                                   x_product_txn_rec.Action_Code);
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;
        END IF;
        -- Get Current submit_order_flag, book_order_flag, release_order_flag and Ship_Order_Flag
        -- statuses and Object_Version_Number values from database
        IF NVL(x_product_txn_rec.product_transaction_id, Fnd_Api.g_miss_num) <>
           Fnd_Api.g_miss_num
        THEN
            OPEN prod_txn(x_product_txn_rec.product_transaction_id);
            FETCH prod_txn
                INTO l_est_detail_id, l_repair_line_id, l_curr_submit_order_flag, l_curr_book_order_flag, l_curr_release_order_flag, l_curr_ship_order_flag, l_object_version_num;
            CLOSE prod_txn;
        END IF;

        IF NVL(x_product_txn_rec.repair_line_id, Fnd_Api.g_miss_num) <>
           Fnd_Api.g_miss_num
        THEN
            IF x_product_txn_rec.repair_line_id <> l_repair_line_id
            THEN
                IF l_exception_level >= l_debug_level
                THEN
                    Fnd_Log.string(l_exception_level,
                                   l_module_name || '.check_in_parameters',
                                   'Repair Line id can not be changed');
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;
        ELSE
            x_product_txn_rec.repair_line_id := l_repair_line_id;
        END IF;

        IF x_product_txn_rec.action_type IN
           (C_Action_Type_Move_Out, C_Action_Type_Move_In)
        THEN
            -- get the incident id for the repair line
            BEGIN
                SELECT incident_id
                  INTO l_incident_id
                  FROM csd_repairs
                 WHERE repair_line_id = l_repair_line_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    Fnd_Message.set_name('CSD', 'CSD_API_INV_REP_LINE_ID');
                    Fnd_Message.set_token('REPAIR_LINE_ID',
                                          l_repair_line_id);
                    Fnd_Msg_Pub.ADD;
                    IF l_statement_level >= l_debug_level
                    THEN
                        Fnd_Log.string(l_statement_level,
                                       l_module_name ||
                                       '.check_in_parameters',
                                       'Invalid repair line id ' ||
                                       x_product_txn_rec.repair_line_id);
                    END IF;
                    RAISE Fnd_Api.g_exc_error;
            END;
            IF l_incident_id IS NOT NULL
            THEN
                OPEN sr_rec(l_incident_id);
                FETCH sr_rec
                    INTO l_party_id, l_account_id;
                CLOSE sr_rec;
            ELSE
                Fnd_Message.set_name('CSD', 'CSD_API_INV_SR_ID');
                Fnd_Message.set_token('INCIDENT_ID', l_incident_id);
                Fnd_Msg_Pub.ADD;
                IF (g_debug > 0)
                THEN
                    Csd_Gen_Utility_Pvt.ADD('incident id  missing ');
                END IF;
                RAISE Fnd_Api.g_exc_error;
            END IF;

            -- assigning values for the order record
            l_order_rec.incident_id := l_incident_id;
            l_order_rec.party_id    := l_party_id;
            l_order_rec.account_id  := l_account_id;
            l_order_rec.org_id      := x_Product_Txn_Rec.Organization_Id;
            -- Do further processing only when process transaction flag is 'Y'
            IF x_product_txn_rec.process_txn_flag = C_Yes
            THEN
                SAVEPOINT release_sales_order;
                -- Do further processing only when process transaction flag values for UI and database
                -- are different and release sales order flag at UI should be checked.
                IF NVL(l_curr_release_order_flag, 'N') <>
                   x_product_txn_rec.release_sales_order_flag AND
                   x_product_txn_rec.release_sales_order_flag = C_Yes
                THEN
                    -- Sub Inventory column will have value if internal requisition has source sub inventory
                    -- value else it will have null values.
                    IF NVL(x_product_txn_rec.sub_inventory,
                           Fnd_Api.g_miss_char) <> Fnd_Api.g_miss_char
                    THEN
                        l_order_rec.pick_from_subinventory   := x_product_txn_rec.sub_inventory;
                        l_order_rec.def_staging_subinventory := x_product_txn_rec.sub_inventory;
                    END IF;
                    -- get the default pick rule id
                    -- Check Action Type and get appropriate picking rule definition
                    --R12 Development Changes
                    -- Changed code to take the profile value onlyif the input record
                    -- picking_rule is null
                    IF (x_product_txn_rec.picking_rule_id IS NULL)
                    THEN
                        IF x_product_txn_rec.Action_Type =
                           C_ACTION_TYPE_MOVE_IN
                        THEN
                            Fnd_Profile.get('csd_pick_release_rule_defect_subinv',
                                            l_picking_rule_id);
                        ELSIF x_product_txn_rec.Action_Type =
                              C_ACTION_TYPE_MOVE_OUT
                        THEN
                            Fnd_Profile.get('csd_pick_release_rule_usable_subinv',
                                            l_picking_rule_id);
                        END IF;
                    ELSE
                        l_picking_rule_id := x_product_txn_rec.picking_rule_id;
                    END IF;
                    -- fnd_profile.get('csd_def_pick_release_rule',l_picking_rule_id);
                    IF l_Statement_level >= l_debug_level
                    THEN
                        Fnd_Log.string(l_Statement_level,
                                       l_module_name,
                                       'Default picking rule id :' ||
                                       l_Picking_Rule_Id);
                    END IF;
                    BEGIN
                        SELECT picking_rule_id
                          INTO l_picking_rule_id
                          FROM wsh_picking_rules
                         WHERE picking_rule_id = l_picking_rule_id
                           AND SYSDATE BETWEEN
                               NVL(start_date_active, SYSDATE) AND
                               NVL(end_date_active, SYSDATE + 1);
                        l_order_rec.picking_rule_id := l_picking_rule_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            Fnd_Message.set_name('CSD',
                                                 'CSD_API_INV_PICKING_RULE_ID');
                            Fnd_Message.set_token('PICKING_RULE_ID',
                                                  l_picking_rule_id);
                            Fnd_Msg_Pub.ADD;
                            IF l_exception_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_exception_level,
                                               l_module_name,
                                               ' Default picking rule id not found');
                            END IF;
                            RAISE release_order_excep;
                    END;
                    BEGIN
                        -- check released_status column value for the delivery line, if even one record is found
                        -- with status ready_for_release or backordered then whole order header needs to be pick released
                        SELECT 'Y'
                          INTO l_order_to_be_pickreleased
                          FROM wsh_delivery_details a
                         WHERE a.source_header_id =
                               x_product_txn_rec.order_header_id
                           AND a.source_line_id =
                               x_product_txn_rec.order_line_id
                           AND a.released_status IN
                               (c_ready_for_release, c_backordered)
                           AND ROWNUM < 2;
                        IF l_statement_level >= l_debug_level
                        THEN
                            Fnd_Log.string(l_statement_level,
                                           l_module_name,
                                           'There are lines eligible for pick release');
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            -- there are no records to be pick released using public api
                            l_order_to_be_pickreleased := C_No;
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'There are no lines eligible for pick releas');
                            END IF;
                    END;
                    l_order_rec.order_header_id := x_product_txn_rec.order_header_id;
                    IF l_order_to_be_pickreleased = C_Yes
                    THEN
                        IF l_statement_level >= l_debug_level
                        THEN
                            Fnd_Log.string(l_statement_level,
                                           l_module_name,
                                           'Calling process_sales_order to release so');
                        END IF;
                        Csd_Process_Pvt.process_sales_order(p_api_version      => 1.0,
                                                            p_commit           => Fnd_Api.g_false,
                                                            p_init_msg_list    => Fnd_Api.g_true,
                                                            p_validation_level => Fnd_Api.g_valid_level_full,
                                                            p_action           => C_Action_Pick_Release,
                                                            p_order_rec        => l_order_rec,
                                                            x_return_status    => x_return_status,
                                                            x_msg_count        => x_msg_count,
                                                            x_msg_data         => x_msg_data);
                        IF (x_return_status = Fnd_Api.g_ret_sts_error)
                        THEN
                            IF l_exception_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_exception_level,
                                               l_module_name,
                                               'csd_process_pvt.process_sales_order failed');
                            END IF;
                            RAISE release_order_excep;
                        ELSE
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'process_sales_order was successful');
                            END IF;
                        END IF; -- X_Return_Status is Error
                    END IF; --l_order_to_be_pickreleased = 'y' then
                    -- Check if there are any delivery lines in status in 'Ready To Releas',
                    -- Released To WareHouse', 'Back ORdered' for a given order header id and
                    -- order line id, if so line is not eligible to stamp for 'Released' status.
                    BEGIN
                        SELECT 'Y'
                          INTO l_order_to_Be_PickReleased
                          FROM wsh_Delivery_Details
                         WHERE source_header_id =
                               x_product_txn_rec.order_header_id
                           AND source_line_id =
                               x_product_txn_Rec.Order_line_id
			   AND SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
                           AND released_Status IN
                               (c_ready_for_release, c_backordered,
                                c_release_to_warehouse);
                        IF l_statement_level >= l_debug_level
                        THEN
                            Fnd_Log.string(l_statement_level,
                                           l_module_name,
                                           'Still there are some lines to be pick released');
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_order_to_Be_PickReleased := 'N';
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'There are no lines to be pick released');
                            END IF;
                        WHEN TOO_MANY_ROWS THEN
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'More then one line to be pick released');
                            END IF;
                            l_order_to_Be_PickReleased := 'Y';
                    END;
                    IF l_order_TO_Be_PickReleased = 'N'
                    THEN
                        -- since pick release process is complete update product transaction lines
                        FOR released_line_rec IN released_lines_cur(x_product_txn_rec.order_header_id,
                                                                    x_product_txn_rec.order_line_id)
                        LOOP
                            -- update product transaction tables
                            UPDATE csd_product_transactions
                               SET prod_txn_status          = C_Status_Released,
                                   release_sales_order_flag = C_Yes,
                                   object_version_number    = Object_Version_Number + 1,
                                   Last_Update_Date         = SYSDATE,
                                   Last_Updated_By          = Fnd_Global.User_Id,
                                   Last_Update_login        = Fnd_Global.Login_Id
                             WHERE order_header_id =
                                   released_line_rec.source_header_id
                               AND order_line_id =
                                   released_line_rec.source_line_id
                               AND NVL(release_sales_order_flag, C_No) = C_No;
                            --
                            IF SQL%FOUND
                            THEN
                                -- Product Transaction records are updated.
                                IF l_statement_level >= l_debug_level
                                THEN
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Product transaction records are updated with Released Status');
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order header id :' ||
                                                   x_product_txn_rec.order_header_id);
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order Line id :' ||
                                                   x_product_txn_rec.order_Line_id);
                                END IF;
                                /****************************
                                RO is not udpated as it is does not make sense to update RO record
                                when ever its product transactions are released. Not applicable to internal ROs.
                                    update csd_repairs
                                    set ro_txn_status            = 'OM_RELEASED' ,
                                       object_version_number    = Object_Version_Number + 1,
                                       Last_Update_Date         = Sysdate,
                                       Last_Updated_By          = Fnd_Global.User_Id,
                                       Last_Update_login        = Fnd_Global.Login_Id
                                    where repair_line_id = x_product_txn_rec.repair_line_id;
                                    if sql%notfound then
                                       fnd_message.set_name('CSD','CSD_ERR_REPAIRS_UPDATE');
                                       fnd_message.set_token('REPAIR_LINE_ID',x_product_txn_rec.repair_line_id);
                                       fnd_msg_pub.add;
                                       raise release_order_excep;
                                    end if;
                                ********************************/
                            ELSE
                                -- No Product Transaction records are updated.
                                IF l_statement_level >= l_debug_level
                                THEN
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'No valid product transaction record found to update release status');
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order header id :' ||
                                                   x_product_txn_rec.order_header_id);
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order Line id :' ||
                                                   x_product_txn_rec.order_Line_id);
                                END IF;
                            END IF; --if sql%found then
                        END LOOP; --released_line_rec in
                    END IF; -- l_order_to_be_PickReleased
                END IF; --end of pick-release sales order

                -- Allow auto shipping only when ship_order_flag has different values for UI and database values.
                -- and ship_sales_order_flag is checked in UI.
                -- Ship-Confirm radio button in UI is disabled for items that are serial controlled at SO issue.
                -- Ship-Confirm radio button is disabled in UIwhen more then one delivery lines exist for a
                -- given order line.
                IF NVL(l_curr_ship_order_flag, 'N') <>
                   x_product_txn_rec.ship_sales_order_flag AND
                   x_product_txn_rec.ship_sales_order_flag = C_Yes
                THEN
                    SAVEPOINT ship_sales_order;
                    l_order_rec.order_header_id := x_product_txn_rec.order_header_id;
                    l_order_rec.order_line_id   := x_product_txn_rec.order_line_id;
                    l_order_rec.serial_number   := x_product_txn_rec.source_serial_number; -- from 11.5.10 release
                    -- Check if there is a delivery line eligible for shipping for a given order line id
                    --Initialize l_Released_Status to NULL
                    l_Released_Status := NULL;
                    BEGIN
                        -- select C_Yes
                        -- into  l_allow_ship
                        SELECT Released_Status
                          INTO l_Released_Status
                          FROM wsh_delivery_details
                         WHERE source_header_id =
                               l_order_rec.order_header_id
                           AND source_line_id = l_order_rec.order_line_id
                           AND released_status IN (C_Staged_PickConfirmed,
                                C_Release_to_warehouse)
			   AND    SOURCE_CODE = 'OE'; /*Fixed for bug#5840654 */
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_allow_ship := C_No;
                            -- fnd_message.set_name('csd','csd_release_failed');
                            Fnd_Message.set_name('CSD',
                                                 'CSD_ORDER_LINE_NOT_SHIPABLE');
                            Fnd_Message.set_token('ORDER_LINE_ID',
                                                  l_order_rec.order_line_id);
                            Fnd_Msg_Pub.ADD;
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'Order line id  ' ||
                                               l_Order_rec.Order_Line_id ||
                                               ' is not eligible for shipping.');
                            END IF;
                            RAISE ship_order_excep;
                        WHEN TOO_MANY_ROWS THEN
                            Fnd_Message.set_name('CSD',
                                                 'CSD_TOO_MANY_ROWS_SHIPABLE');
                            Fnd_Message.set_token('ORDER_LINE_ID',
                                                  l_order_rec.order_line_id);
                            Fnd_Msg_Pub.ADD;
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               'Order line id  ' ||
                                               l_Order_rec.Order_Line_id ||
                                               ' has more then one delivery lines.');
                            END IF;
                    END;
                    -- if l_allow_ship = C_Yes then
                    IF l_Released_Status = C_Staged_PickConfirmed
                    THEN
                        IF l_statement_level >= l_debug_level
                        THEN
                            Fnd_Log.string(l_statement_level,
                                           l_module_name,
                                           'Calling Process Sales Order API');
                        END IF;
                        Csd_Process_Pvt.process_sales_order(p_api_version      => 1.0,
                                                            p_commit           => Fnd_Api.g_false,
                                                            p_init_msg_list    => Fnd_Api.g_true,
                                                            p_validation_level => Fnd_Api.g_valid_level_full,
                                                            p_action           => C_Action_Ship,
                                                            p_order_rec        => l_order_rec,
                                                            x_return_status    => x_return_status,
                                                            x_msg_count        => x_msg_count,
                                                            x_msg_data         => x_msg_data);
                        IF NOT (x_return_status = Fnd_Api.g_ret_sts_success)
                        THEN
                            IF l_statement_level >= l_debug_level
                            THEN
                                Fnd_Log.string(l_statement_level,
                                               l_module_name,
                                               ' process sales order failed');
                            END IF;
                            RAISE ship_order_excep;
                        END IF; -- If x_return_status <> fnd_api.g_ret_sts_success
                    END IF; -- l_allow_ship = C_Yes
                    -- Check if any of the delivery lines status are less then 'Shipped'
                    --  for a given order header id and order line id , if so do not update
                    -- product txn lines with Shipped status, if not then update product txn table
                    BEGIN
                        SELECT 'Y'
                          INTO l_order_to_Be_Shipped
                          FROM wsh_Delivery_Details
                         WHERE source_header_id =
                               x_product_txn_rec.order_header_id
                           AND source_line_id =
                               x_product_txn_Rec.Order_line_id
			   AND SOURCE_CODE = 'OE' /*Fixed for bug#5846054*/
                           AND released_Status IN
                               (c_ready_for_release, c_backordered,
                                c_release_to_warehouse,
                                c_staged_pickconfirmed);
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                            l_order_to_Be_shipped := 'N';
                    END;

                    IF l_order_to_Be_Shipped = 'N'
                    THEN
                        -- since there are no records to be shipped
                        -- shipping process is complete update product transaction lines
                        FOR Shipped_line_rec IN Shipped_lines_cur(x_product_txn_rec.order_header_id,
                                                                  x_product_txn_rec.Order_line_id)
                        LOOP
                            -- update product transaction tables
                            UPDATE csd_product_transactions
                               SET -- prod_txn_status          = C_Status_Shipped ,
                                   release_sales_order_flag = C_Yes,
                                   ship_sales_order_flag    = C_Yes,
                                   object_version_number    = Object_Version_Number + 1,
                                   Last_Update_Date         = SYSDATE,
                                   Last_Updated_By          = Fnd_Global.User_Id,
                                   Last_Update_login        = Fnd_Global.Login_Id
                             WHERE order_header_id =
                                   shipped_line_rec.source_header_id
                               AND order_line_id =
                                   shipped_line_rec.source_line_id
                               AND NVL(ship_sales_order_flag, C_No) = C_No;
                            --
                            IF SQL%FOUND
                            THEN
                                -- Product Transaction records are updated.
                                IF l_statement_level >= l_debug_level
                                THEN
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Product transaction records are updated with Shipped Status');
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order header id :' ||
                                                   x_product_txn_rec.order_header_id);
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order Line id :' ||
                                                   x_product_txn_rec.order_Line_id);
                                END IF;
                                /*****************
                                No need to update repairs block when ever its product transaction
                                line is shipped. One repair order line can have more then one product
                                transaction line and if we update RO when ever it is released or
                                shipped then ro_txn_Status will not be of much use.
                                    Update csd_repairs
                                       Set ro_txn_status = 'OM_SHIPPED' ,
                                          object_version_number    = Object_Version_Number + 1,
                                          Last_Update_Date         = Sysdate,
                                          Last_Updated_By          = Fnd_Global.User_Id,
                                          Last_Update_login        = Fnd_Global.Login_Id
                                    Where repair_line_id = x_product_txn_rec.repair_line_id;
                                    If sql%notfound then
                                       fnd_message.set_name('CSD','CSD_ERR_REPAIRS_UPDATE');
                                       fnd_message.set_token('REPAIR_LINE_ID',x_product_txn_rec.repair_line_id);
                                       fnd_msg_pub.add;
                                       Raise release_order_excep;
                                    End if;
                                *****************/
                            ELSE
                                -- No Product Transaction records are updated.
                                IF l_statement_level >= l_debug_level
                                THEN
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'No valid product transaction record found to update to shipped status');
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order header id :' ||
                                                   x_product_txn_rec.order_header_id);
                                    Fnd_Log.string(l_statement_level,
                                                   l_module_name,
                                                   'Internal Order Line id :' ||
                                                   x_product_txn_rec.order_Line_id);
                                END IF;
                            END IF; --if sql%found then
                        END LOOP; --shipped_line_rec in
                    END IF; -- if l_order_to_be_shipped
                END IF; -- end of ship sales order
            END IF; --end of process txn
        END IF; -- Action Type = MOVE_OUt
        -- standard check of p_commit.
        IF Fnd_Api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
    EXCEPTION
        WHEN release_order_excep THEN
            -- Set return status to unexpected error
            x_return_status := Fnd_Api.g_ret_sts_success;
            -- If there is any error  then rollback
            ROLLBACK TO release_sales_order;
            -- Standard procedure to get error message count and error message is also returned
            -- if error message count is 1
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN ship_order_excep THEN
            -- Set return status to unexpected error
            x_return_status := Fnd_Api.g_ret_sts_success;
            -- If there is any error  then rollback
            ROLLBACK TO ship_sales_order;
            -- Standard procedure to get error message count and error message is also returned
            -- if error message count is 1
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.g_exc_error THEN
            -- Set return status to unexpected error
            x_return_status := Fnd_Api.g_ret_sts_error;
            -- If there is any error  then rollback
            ROLLBACK TO update_iro_product_txn;
            -- Standard procedure to get error message count and error message is also returned
            -- if error message count is 1
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.g_exc_unexpected_error THEN
            -- Set return status to unexpected error
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            -- If there is any error  then rollback
            ROLLBACK TO update_iro_product_txn;
            -- Standard procedure to get error message count and error message is also returned
            -- if error message count is 1
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            -- Set return status to unexpected error
            x_return_status := Fnd_Api.g_ret_sts_unexp_error;
            -- If there is any error  then rollback
            ROLLBACK TO update_iro_product_txn;
            IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.g_msg_lvl_unexp_error)
            THEN
                -- Standard way to add sql error message to stack
                Fnd_Msg_Pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;
            -- Standard procedure to get error message count and error message is also returned
            -- if error message count is 1
            Fnd_Msg_Pub.count_and_get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END update_iro_product_txn;


    /*----------------------------------------------------------------------*/
    /*** Forward porting bug# 3877328  */
    /*----------------------------------------------------------------------*/
    /* procedure name: create_default_prod_txn_wrapr                        */
    /* description   : Is a wrapper procedure which does validations before */
    /*                 calling procedure create_default_prod_txn.           */
    /*                 This API will have same parameters as procedure      */
    /*                 create_default_prod_txn. After successful validation */
    /*                 wrapper API will pass same input parameters.         */
    /*----------------------------------------------------------------------*/

    PROCEDURE Create_Default_Prod_Txn_wrapr(p_api_version           IN NUMBER,
                                            p_commit                IN VARCHAR2,
                                            p_init_msg_list         IN VARCHAR2,
                                            p_validation_level      IN NUMBER,
                                            p_repair_line_id        IN NUMBER,
                                            x_return_status         OUT NOCOPY VARCHAR2,
                                            x_msg_count             OUT NOCOPY NUMBER,
                                            x_msg_data              OUT NOCOPY VARCHAR2,
                                            x_Logistics_KeyAttr_Tbl OUT NOCOPY Csd_Process_Pvt.Logistics_KeyAttr_Tbl_Type) IS
        l_api_name    CONSTANT VARCHAR2(30) := 'Create_Default_Prod_Txn_Wrapr';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count               NUMBER;
        l_msg_data                VARCHAR2(2000);
        l_Serial_num_Control_Code NUMBER;
        l_RO_Status               VARCHAR2(30);
        l_RO_Status_Meaning       VARCHAR2(80);
        l_RO_Quantity             NUMBER;
        l_Inventory_Item_id       NUMBER;
        l_RO_Repair_Type_Ref      VARCHAR2(30);
        l_Prod_Txn_Lines_Count    NUMBER;
        l_RO_Number               NUMBER;
        l_Service_Valdn_Org_Name  VARCHAR2(240);
        l_Item_Name               VARCHAR2(240);
        -- Define Constants here
        C_RO_Status_Open           VARCHAR2(30) := 'O';
        C_Repair_Type_Ref_Standard VARCHAR2(10) := 'SR';

        i BINARY_INTEGER; -- loop variable

        -- Define Cursor to get all product transaction lines rec information for a repair order
        CURSOR Logistic_KeyAttr_Cur_Type(p_Repair_Line_Id IN NUMBER) IS
            SELECT cpt.product_Transaction_Id,
                   ced.Estimate_Detail_Id,
                   ced.order_header_Id,
                   ced.order_Line_Id
              FROM csd_product_Transactions cpt, cs_estimate_Details ced
             WHERE cpt.repair_line_id = p_Repair_Line_Id
               AND cpt.estimate_detail_id = ced.estimate_detail_id;
    BEGIN
        -- Standard call to check for call compatibility.
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            RAISE Fnd_Api.G_Exc_UnExpected_Error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

        -- Api body starts
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.dump_api_info(p_pkg_name => G_PKG_NAME,
                                              p_api_name => l_api_name);
        END IF;
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Checking required parameter:(repair_line_id)');
        END IF;
        -- Check the required parameter
        Csd_Process_Util.Check_Reqd_Param(p_param_value => p_Repair_Line_id,
                                          p_param_name  => 'Repair_Line_Id',
                                          p_api_name    => l_api_name);
        -- Validate Repair_Line_id and check RO status
        IF (g_debug > 0)
        THEN
            Csd_Gen_Utility_Pvt.ADD('Required parameter:(repair_line_id) has value' ||
                                    p_Repair_Line_id);
        END IF;
        BEGIN
            IF (g_debug > 0)
            THEN
                Csd_Gen_Utility_Pvt.ADD('Querying csd_repairs_v view');
            END IF;
            SELECT dra.status,
                   dra.Quantity,
                   dra.Inventory_Item_Id,
                   drtvl.Repair_Type_Ref,
                   dra.Repair_Number,
                   fndl2.meaning
              INTO l_RO_Status,
                   l_RO_Quantity,
                   l_Inventory_Item_id,
                   l_RO_Repair_Type_Ref,
                   l_RO_Number,
                   l_RO_Status_Meaning
              FROM csd_repairs dra, fnd_lookups fndl2, csd_repair_types_vl drtvl
             WHERE repair_line_id = p_Repair_line_id
		       and dra.repair_type_id = drtvl.repair_type_id
			  and dra.status = fndl2.lookup_code
                 and fndl2.lookup_type = 'CSD_REPAIR_STATUS';
            -- If Repair Number is Null then Repair_line_id is invalid
            -- Now Check RO_Status , if RO_Status is not Open then raise error
            IF l_RO_Status <> C_RO_Status_Open
            THEN
                -- Display message: Repair Order is in status || l_RO_Status. Default product transaction lines are
                -- not created.
                -- Message Code CSD_RO_NOT_OPEN_NO_PRODTXN_LINES
                -- Raise Error message
                Fnd_Message.SET_NAME('CSD',
                                     'CSD_RO_NOT_OPEN_NO_PRODTXN_LNS');
                Fnd_Message.SET_TOKEN('RO_NUMBER', l_RO_Number);
                Fnd_Message.SET_TOKEN('RO_STATUS', l_RO_Status_Meaning);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            -- Check if repair Type Ref is Standard
            IF l_RO_Repair_Type_Ref = C_Repair_TYpe_Ref_Standard
            THEN
                -- Display message: Default product transaction lines are not created for standard repair type ref
                -- CSD_STD_REP_TYPE_NO_PRODUCTXN_LINES
                Fnd_Message.SET_NAME('CSD',
                                     'CSD_STD_REPTYPE_NO_PRODTXN_LNS');
                Fnd_Message.SET_TOKEN('RO_NUMBER', l_RO_Number);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
            END IF;
            -- Check Serial control code if quantity is greater then 1
            IF l_RO_Quantity > 1
            THEN
                BEGIN
                    SELECT Serial_Number_Control_COde
                      INTO l_Serial_num_COntrol_Code
                      FROM Mtl_System_Items_B
                     WHERE Inventory_Item_Id = l_Inventory_Item_Id
                       AND Organization_id = Cs_Std.Get_Item_Valdn_Orgzn_Id;
                    -- If item is serial controlled then raise error
                    IF l_Serial_num_COntrol_Code > 1
                    THEN
                        -- Display Message: RO quantity can not be greater then for serial controlled items.
                        -- CSD_RO_QTY_MORE_FOR_SERIAL_ITEM
                        -- Raise G_Exc_Error,
                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_RO_QTY_MORE_FOR_SRLCT_ITEM');
                        Fnd_Msg_Pub.ADD;
                        RAISE Fnd_Api.G_EXC_ERROR;
                    END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        -- Get Item Name
                        SELECT items.concatenated_segments
                          INTO l_Item_Name
                          FROM mtl_system_items_vl items, csd_repairs dra
                         WHERE dra.repair_line_id = p_Repair_Line_Id
                             and dra.inventory_item_id = items.inventory_item_id
					    and items.organization_id = cs_std.get_item_valdn_orgzn_id;

                        -- Get Service Validation Org name
                        SELECT Name
                          INTO l_Service_Valdn_Org_Name
                          FROM Hr_Organization_Units
                         WHERE Organization_id =
                               Cs_Std.Get_Item_Valdn_Orgzn_Id;

                        Fnd_Message.SET_NAME('CSD',
                                             'CSD_NO_ITEM_FOR_SRV_VALDN_ORG');
                        Fnd_Message.Set_Token('ITEM', l_Item_Name);
                        Fnd_Message.Set_Token('ORG_NAME',
                                              l_Service_Valdn_Org_Name);
                        Fnd_Msg_Pub.ADD;
                        RAISE Fnd_Api.G_EXC_ERROR;

                END;
            END IF;
            -- CHeck if there are any product txn lines for a given repair line id
            BEGIN
                SELECT COUNT(Product_Transaction_Id)
                  INTO l_Prod_Txn_Lines_Count
                  FROM csd_product_Transactions
                 WHERE Repair_Line_id = p_Repair_Line_Id;
                IF l_Prod_Txn_Lines_Count > 0
                THEN
                    -- Default product transaction lines are not created as product transaction lines exist
                    -- for Repair Order : l_RO_number
                    -- CSD_RO_HAS_PRODTXN_LINES
                    -- RAise G_Exc_Error
                    Fnd_Message.SET_NAME('CSD',
                                         'CSD_RO_HAS_PRODUCT_TXN_LINES');
                    Fnd_Message.SET_TOKEN('RO_NUMBER', l_RO_Number);
                    Fnd_Msg_Pub.ADD;
                    RAISE Fnd_Api.G_EXC_ERROR;
                END IF;
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                -- Message Code CSD_REPAIR_LINE_ID_INVALID
                -- Display message; Invalid repair line id is passed
                Fnd_Message.SET_NAME('CSD', 'CSD_API_INV_REP_LINE_ID');
                Fnd_Message.SET_TOKEN('REPAIR_LINE_ID', P_Repair_Line_ID);
                Fnd_Msg_Pub.ADD;
                RAISE Fnd_Api.G_EXC_ERROR;
        END;
        -- Now call Default Product Txn lines API

        create_default_prod_txn(p_api_version,
                                p_commit,
                                p_init_msg_list,
                                p_validation_level,
                                p_repair_line_id,
								Fnd_Api.g_false,
                                x_return_status,
                                x_msg_count,
                                x_msg_Data);

        -- Once default product transaction lines are created successfully,
        -- assign new entities to new out variable x_Logistics_KeyAttr_Tbl.
        IF NOT (x_return_status = Fnd_Api.G_RET_STS_SUCCESS)
        THEN
            RAISE Fnd_Api.G_EXC_ERROR;
        ELSE
            --  New code added here
            i := 0; -- Initialize loop variable to zero
            FOR Logistic_KeyAttr_Rec IN Logistic_KeyAttr_Cur_Type(p_Repair_line_id)
            LOOP
                i := i + 1;
                x_Logistics_KeyAttr_Tbl(i).Product_Transaction_Id := Logistic_KeyAttr_Rec.Product_Transaction_Id;
                x_Logistics_KeyAttr_Tbl(i).Estimate_Detail_Id := Logistic_KeyAttr_Rec.Estimate_Detail_Id;
                x_Logistics_KeyAttr_Tbl(i).Order_Header_Id := Logistic_KeyAttr_Rec.Order_Header_Id;
                x_Logistics_KeyAttr_Tbl(i).Order_Line_Id := Logistic_KeyAttr_Rec.Order_Line_Id;
            END LOOP;
        END IF;

    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
    END Create_Default_Prod_Txn_Wrapr;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* R12 Quality Integration */
    /* procedure name: create_repair_task                                                                               */
    /* description   : procedure used to create DR specific tasks in Depot tables                                                            */
    /* Called from   : Depot Repair Form to Create Task                                                          */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 p_CREATE_REPAIR_TASK_REC  RECORD      Required Columns are in the Record REPAIR_TASK_REC_TYPE */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*                 x_task_id             NUMBER               Task Id of the created Task                    */
    /*-----------------------------------------------------------------------------------------------------------*/
    PROCEDURE CREATE_REPAIR_TASK(p_api_version            IN NUMBER,
                                 p_init_msg_list          IN VARCHAR2 := Fnd_Api.g_false,
                                 p_commit                 IN VARCHAR2 := Fnd_Api.g_false,
                                 p_validation_level       IN NUMBER := Fnd_Api.g_valid_level_full,
                                 p_create_repair_task_rec IN REPAIR_TASK_REC,
                                 x_return_status          OUT NOCOPY VARCHAR2,
                                 x_msg_count              OUT NOCOPY NUMBER,
                                 x_msg_data               OUT NOCOPY VARCHAR2,
                                 x_repair_task_id         OUT NOCOPY NUMBER) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'CREATE_REPAIR_TASK';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);
        l_msg_index     NUMBER;
        l_return_status VARCHAR2(1);

        -- Task record
        l_create_task_rec     Csd_Process_Pvt.REPAIR_TASK_REC := p_create_repair_task_rec;
        l_applicable_qa_plans VARCHAR2(1);
        l_plan_txn_ids        VARCHAR2(5000);
        l_dummy_char          VARCHAR2(32000);

        -- define variables to define fnd_log debug levels
        l_debug_level NUMBER := Fnd_Log.g_current_runtime_level;
        -- examples : 1- copying buffer x to y : low level detailed messages
        l_statement_level NUMBER := Fnd_Log.level_statement;
        -- examples : 2- key progress events : starting business transactions
        l_procedure_level NUMBER := Fnd_Log.level_procedure;
        -- examples : 3- event  : calling an api, key progress events
        l_event_level NUMBER := Fnd_Log.level_event;
        -- examples : 4- exception  internal software failure condition
        l_exception_level NUMBER := Fnd_Log.level_exception;
        -- examples : 5- error  end user erros
        l_error_level NUMBER := Fnd_Log.level_error;
        l_module_name VARCHAR2(240) := 'csd.plsql.csd_process_pvt.create_repair_task';

    BEGIN
        -- -----------------
        -- Begin create repair task
        -- -----------------

        -- Standard Start of API savepoint
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level, l_module_name, 'begin');
        END IF;
        SAVEPOINT create_repair_task;

        -- Standard call to check for call compatibility.
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility');
        END IF;
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            IF l_exception_level >= l_debug_level
            THEN
                Fnd_Log.string(l_exception_level,
                               l_module_name,
                               'checking api compatibility, was unsuccessful');
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility, was successful');
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------
        -- Api body starts
        -- ---------------
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Task Record Values:');
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Task Id   :' ||
                           p_create_repair_task_rec.task_Id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Repair_line_id           :' ||
                           p_create_repair_task_rec.repair_line_id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'context values              :' ||
                           p_create_repair_task_rec.context_values);
        END IF;

        -- check the required parameter

        Csd_Process_Util.check_reqd_param(p_param_value => p_create_repair_task_rec.task_Id,
                                          p_param_name  => 'Task Id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'Task id is valid');
        END IF;

        Csd_Process_Util.check_reqd_param(p_param_value => p_create_repair_task_rec.repair_line_Id,
                                          p_param_name  => 'Repair Line Id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'Repair Line id is valid');
        END IF;

        -- Determine if any plans are applicable for this task.
        l_dummy_char := Qa_Txn_Grp.evaluate_triggers(p_txn_number     => G_DEPOT_REPAIR_TXN_NUMBER,
                                                     p_org_id         => p_create_repair_task_rec.org_id,
                                                     p_context_values => p_create_repair_task_rec.context_values,
                                                     x_plan_txn_ids   => l_plan_txn_ids);

        IF l_plan_txn_ids IS NOT NULL
        THEN
            l_applicable_qa_plans := 'Y';
        ELSE
            l_applicable_qa_plans := 'N';
        END IF;

        -- Insert into CSD_TASKS table
        Csd_Tasks_Pkg.INSERT_ROW(px_repair_task_id       => x_repair_task_id,
                                 p_TASK_ID               => p_create_repair_task_rec.task_id,
                                 p_OBJECT_VERSION_NUMBER => 1,
                                 p_REPAIR_LINE_ID        => p_create_repair_task_rec.repair_line_id,
                                 p_APPLICABLE_QA_PLANS   => l_applicable_qa_plans,
                                 p_CREATED_BY            => Fnd_Global.USER_ID,
                                 p_CREATION_DATE         => SYSDATE,
                                 p_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
                                 p_LAST_UPDATE_DATE      => SYSDATE,
                                 p_LAST_UPDATE_LOGIN     => Fnd_Global.USER_ID);

        -- -------------------
        -- Api body ends here
        -- -------------------
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO create_task;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_task;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO create_task;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END CREATE_REPAIR_TASK;

    /*-----------------------------------------------------------------------------------------------------------*/
    /* R12 Quality Integration */
    /* procedure name: update_repair_task                                                                               */
    /* description   : procedure used to update DR specifc task in Depot tables                                                             */
    /* Called from   : Depot Repair Form to Update DR specifc Task                                                          */
    /* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
    /*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
    /*                                                            default value is fnd_api.g_false               */
    /*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
    /*                                                            fnd_api.g_false                                */
    /*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
    /*                                                            validation steps must be done and which steps  */
    /*                                                            should be skipped.                             */
    /*                 CREATE_REPAIR_TASK_REC RECORD      Required Columns are in the Record CREATE_REPAIR_TASK_REC_TYPE */
    /* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
    /*                                                            fnd_api.g_ret_sts_success (success)            */
    /*                                                            fnd_api.g_ret_sts_error (error)                */
    /*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
    /*                 x_msg_count           NUMBER               Number of messages in the message stack        */
    /*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
    /*-----------------------------------------------------------------------------------------------------------*/

    PROCEDURE UPDATE_REPAIR_TASK(p_api_version            IN NUMBER,
                                 p_init_msg_list          IN VARCHAR2 := Fnd_Api.g_false,
                                 p_commit                 IN VARCHAR2 := Fnd_Api.g_false,
                                 p_validation_level       IN NUMBER := Fnd_Api.g_valid_level_full,
                                 p_update_repair_task_rec IN REPAIR_TASK_REC,
                                 x_return_status          OUT NOCOPY VARCHAR2,
                                 x_msg_count              OUT NOCOPY NUMBER,
                                 x_msg_data               OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30) := 'update_REPAIR_TASK';
        l_api_version CONSTANT NUMBER := 1.0;
        l_msg_count     NUMBER;
        l_msg_data      VARCHAR2(2000);
        l_msg_index     NUMBER;
        l_return_status VARCHAR2(1);

        -- Task record
        l_update_task_rec     Csd_Process_Pvt.REPAIR_TASK_REC := p_update_repair_task_rec;
        l_applicable_qa_plans VARCHAR2(1);
        l_dummy_char          VARCHAR2(32000);
        l_plan_txn_ids        VARCHAR2(5000);

        -- define variables to define fnd_log debug levels
        l_debug_level NUMBER := Fnd_Log.g_current_runtime_level;
        -- examples : 1- copying buffer x to y : low level detailed messages
        l_statement_level NUMBER := Fnd_Log.level_statement;
        -- examples : 2- key progress events : starting business transactions
        l_procedure_level NUMBER := Fnd_Log.level_procedure;
        -- examples : 3- event  : calling an api, key progress events
        l_event_level NUMBER := Fnd_Log.level_event;
        -- examples : 4- exception  internal software failure condition
        l_exception_level NUMBER := Fnd_Log.level_exception;
        -- examples : 5- error  end user erros
        l_error_level NUMBER := Fnd_Log.level_error;
        l_module_name VARCHAR2(240) := 'csd.plsql.csd_process_pvt.update_repair_task';

    BEGIN
        -- -----------------
        -- Begin update repair task
        -- -----------------

        -- Standard Start of API savepoint
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level, l_module_name, 'begin');
        END IF;
        SAVEPOINT update_repair_task;

        -- Standard call to check for call compatibility.
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility');
        END IF;
        IF NOT Fnd_Api.Compatible_API_Call(l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
        THEN
            IF l_exception_level >= l_debug_level
            THEN
                Fnd_Log.string(l_exception_level,
                               l_module_name,
                               'checking api compatibility, was unsuccessful');
            END IF;
            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name,
                           'checking api compatibility, was successful');
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF Fnd_Api.to_Boolean(p_init_msg_list)
        THEN
            Fnd_Msg_Pub.initialize;
        END IF;
        -- Initialize API return status to success
        x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
        -- ---------------
        -- Api body starts
        -- ---------------
        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Task Record Values:');
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Task Id   :' ||
                           p_update_repair_task_rec.task_Id);
            Fnd_Log.String(l_Statement_Level,
                           l_Module_Name,
                           'Repair_line_id           :' ||
                           p_update_repair_task_rec.repair_line_id);
            -- fnd_log.String(l_Statement_Level,l_Module_Name,'Applicable QA Plans              :'||  p_update_repair_task_rec.applicable_qa_plans );
        END IF;

        -- check the required parameter
        Csd_Process_Util.check_reqd_param(p_param_value => p_update_repair_task_rec.repair_task_Id,
                                          p_param_name  => 'Task Id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'Repair Task id is valid');
        END IF;

        Csd_Process_Util.check_reqd_param(p_param_value => p_update_repair_task_rec.task_Id,
                                          p_param_name  => 'Task Id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'Task id is valid');
        END IF;

        Csd_Process_Util.check_reqd_param(p_param_value => p_update_repair_task_rec.repair_line_Id,
                                          p_param_name  => 'Repair Line Id',
                                          p_api_name    => l_api_name);

        IF l_statement_level >= l_debug_level
        THEN
            Fnd_Log.string(l_statement_level,
                           l_module_name || '.check_in_parameters',
                           'Repair Line id is valid');
        END IF;

        -- Determine if any plans are applicable for this task.
        l_dummy_char := Qa_Txn_Grp.evaluate_triggers(p_txn_number     => G_DEPOT_REPAIR_TXN_NUMBER,
                                                     p_org_id         => p_update_repair_task_rec.org_id,
                                                     p_context_values => p_update_repair_task_rec.context_values,
                                                     x_plan_txn_ids   => l_plan_txn_ids);

        IF l_plan_txn_ids IS NOT NULL
        THEN
            l_applicable_qa_plans := 'Y';
        ELSE
            l_applicable_qa_plans := 'N';
        END IF;

        -- Update CSD_TASKS table
        Csd_Tasks_Pkg.UPDATE_ROW(px_REPAIR_TASK_ID       => p_update_repair_task_rec.repair_task_id,
                                 p_task_id               => p_update_repair_task_rec.task_id,
                                 p_OBJECT_VERSION_NUMBER => p_update_repair_task_rec.object_version_number,
                                 p_REPAIR_LINE_ID        => p_update_repair_task_rec.repair_line_id,
                                 p_APPLICABLE_QA_PLANS   => l_applicable_qa_plans,
                                 p_CREATED_BY            => Fnd_Global.USER_ID,
                                 p_CREATION_DATE         => SYSDATE,
                                 p_LAST_UPDATED_BY       => Fnd_Global.USER_ID,
                                 p_LAST_UPDATE_DATE      => SYSDATE,
                                 p_LAST_UPDATE_LOGIN     => Fnd_Global.USER_ID);

        -- -------------------
        -- Api body ends here
        -- -------------------
        -- Standard check of p_commit.
        IF Fnd_Api.To_Boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;
        -- Standard call to get message count and IF count is  get message info.
        Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                  p_data  => x_msg_data);
    EXCEPTION
        WHEN Fnd_Api.G_EXC_ERROR THEN
            ROLLBACK TO update_repair_task;
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_task;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);
        WHEN OTHERS THEN
            x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
            ROLLBACK TO update_repair_task;
            IF Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
            THEN
                Fnd_Msg_Pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
            END IF;
            Fnd_Msg_Pub.Count_And_Get(p_count => x_msg_count,
                                      p_data  => x_msg_data);

    END UPDATE_REPAIR_TASK;

    FUNCTION GET_REPAIR_TASK_REC RETURN Csd_Process_Pvt.REPAIR_TASK_REC IS
        TMP_REPAIR_TASK_REC Csd_Process_Pvt.REPAIR_TASK_REC;
    BEGIN
        RETURN TMP_REPAIR_TASK_REC;
    END GET_REPAIR_TASK_REC;
END Csd_Process_Pvt;

/
