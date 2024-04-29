--------------------------------------------------------
--  DDL for Package INV_3PL_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_3PL_BILLING_PUB" AUTHID CURRENT_USER AS
/* $Header: INVPBLRS.pls 120.0.12010000.1 2010/01/16 15:07:47 gjyoti noship $ */

    TYPE source_rec_type IS RECORD
        (   client_code            mtl_client_parameters.client_code%TYPE,
            client_id              mtl_client_parameters.client_id%TYPE,
            client_number          mtl_client_parameters.client_number%TYPE,
            client_name            hz_parties.party_name%TYPE,
            operating_unit         org_organization_definitions.operating_unit%TYPE,
            last_invoice_date      oks_level_elements.date_transaction%TYPE,
            last_interface_date    oks_level_elements.date_to_interface%TYPE,
            billing_uom            mtl_units_of_measure_vl.uom_code%TYPE,
            last_reading           csi_counter_readings.net_reading%TYPE,
            last_computation_Date  csi_counter_readings.value_timestamp%TYPE,
            service_line_start_date okc_k_lines_b.start_date%TYPE,
            source_to_date          DATE
        );

    g_billing_source_rec source_rec_type;

    FUNCTION set_billing_source_rec
            (
                p_billing_source_rec source_rec_type
            ) RETURN BOOLEAN;

END INV_3PL_BILLING_PUB;

/
