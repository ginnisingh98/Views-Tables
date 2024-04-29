--------------------------------------------------------
--  DDL for Package ITG_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ITG_SETUP" AUTHID CURRENT_USER AS
/* $Header: itghlocs.pls 120.2 2005/12/22 04:15:11 bsaratna noship $ */

        -- Name
        --      setup
        -- Purpose
        --      This procedure is called from a concurrent program(can be called from anywhere actually).
        --      This procedure does the setup required for ITG
        --              i)      Setup default TP location in HR_LOCATIONS
        --              ii)     Setup XMLGateway trading partner definition
        --              iii)    Enable all the ITG triggers
        --      HR_LOCATIONS_ALL table. This is required for the ITG XMLGateway trading partner setup.
        -- Arguments
        --      x_err_buf                       => API out result param for concurrent program calls
        --      x_retcode                       => API out result param for concurrent program calls
        -- Notes
        --      All the input arguments are used in the call to setup_hr_locations
        --      The concurrent program will be failed in case of any error
        PROCEDURE setup(
                                          x_errbuf         OUT NOCOPY VARCHAR2,
                                          x_retcode        OUT NOCOPY NUMBER
                                );

        -- Name
        --      setup_hr_loc
        -- Purpose
        --      This procedure sets up the ITG default trading partner information (OIPC Default TP) in the
        --      HR_LOCATIONS_ALL table. This is required for the ITG XMLGateway trading partner setup.
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_location_code                 => Should have value 'OIPC Default TP'
        --      p_description                   => Some description
        --      p_addr_line_1                   => Some address line 1
        --      p_country                       => Some country
        --      p_style                         => Some address style
        -- Notes
        --      We really do not care what value go in here so long as a record
        --      with location code 'OIPC Default TP' is created in Hr_Locations table
        --      All the params input here are mandatory, to the HR APIs which create a location
        --      Defaulting is done in the Concurrent Program definition which wraps this call
        PROCEDURE setup_hr_loc(
                                          x_errbuf         OUT NOCOPY VARCHAR2,
                                          x_retcode        OUT NOCOPY VARCHAR2,
                                          p_location_code  IN VARCHAR2,
                                          p_description    IN VARCHAR2,
                                          p_addr_line_1    IN VARCHAR2,
                                          p_country        IN VARCHAR2,
                                          p_style          IN VARCHAR2
                                );

        -- Name
        --      setup_ecx_tp_header
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup Header block
        --      for a given location code
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_location_code                 => location code for which TP setup is defined
        -- Notes
        --      The given location code should already be present in HR_Locations_all
        PROCEDURE setup_ecx_tp_header(
                                          x_errbuf         OUT NOCOPY VARCHAR2,
                                          x_retcode        OUT NOCOPY VARCHAR2,
                                          x_tp_hdr_id      OUT NOCOPY NUMBER,
                                          p_location_code  IN VARCHAR2,
                                          p_email_id       IN VARCHAR2
                                );

        -- Name
        --      setup_tp_details
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup Details block
        --      for a given location code. i.e. all the transactions for ITG and mappings
        --      are seeded here
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      p_location_code                 => ECX Tp Header id for given location
        -- Notes
        --      The given location code should already be present in HR_Locations_all
        PROCEDURE setup_tp_details(
                                        x_errbuf        OUT NOCOPY VARCHAR2,
                                        x_retcode       OUT NOCOPY VARCHAR2,
                                        p_tp_hdr_id     NUMBER);

        -- Name
        --      add_or_update_tp_detail
        -- Purpose
        --      This procedure sets up the XMLGateway Trading Partner Setup detail
        --      for a single transaction based on the params
        --      If detail record is present it updates else inserts
        -- Arguments
        --      x_err_buf                       => API param for concurrent program calls
        --      x_retcode                       => API param for concurrent program calls
        --      <paramlist>                     => corresponds to the ecx_tp_api, nothing to talk abt
        -- Notes
        --      none
        PROCEDURE add_or_update_tp_detail(
                                                x_errbuf        OUT NOCOPY VARCHAR2,
                                                x_retcode       OUT NOCOPY VARCHAR2,
                                                x_tp_dtl_id     NUMBER,
                                                p_txn_type      VARCHAR2,
                                                p_txn_subtype   VARCHAR2,
                                                p_std_code      VARCHAR2,
                                                p_ext_type      VARCHAR2,
                                                p_ext_subtype   VARCHAR2,
                                                p_direction     VARCHAR2,
                                                p_map           VARCHAR2,
                                                p_conn_type     VARCHAR2,
                                                p_hub_user_id   NUMBER,
                                                p_protocol      VARCHAR2,
                                                p_protocol_addr VARCHAR2,
                                                p_user          VARCHAR2,
                                                p_passwd        VARCHAR2,
                                                p_routing_id    NUMBER,
                                                p_src_loc       VARCHAR2,
                                                p_ext_loc       VARCHAR2,
                                                p_doc_conf      NUMBER,
                                                p_tp_hdr_id     NUMBER,
                                                p_party_type    VARCHAR2

                                         );

        -- Name
        --      trigger_control
        -- Purpose
        --      Enable or disable all the V3 Connector triggers based on the
        --      boolean value of the p_enable argument.
        -- Arguments
        --      x_errbuf                       => API error mesg param
        --      x_retcode                      => API result param
        --      p_enable                       => true - enable / false - disable trigger
        -- Notes
        --      The trigger list here MUST track the list of triggers
        --      created in itgoutev.sql
        PROCEDURE trigger_control(
                                        x_errbuf       OUT NOCOPY VARCHAR2,
                                        x_retcode      OUT NOCOPY VARCHAR2,
                                        p_enable       BOOLEAN);

        -- Name
        --      set_errmesg
        -- Purpose
        --      Helper routine, wraps FND_MESSAGE API call
        -- Arguments
                --      x_err_buf       => FND message containing error with context info
                --      p_errcode       => Error code
                --      p_errmesg       => Error message
        -- Notes
        --      None
        PROCEDURE set_errmesg(          x_errbuf          OUT NOCOPY VARCHAR2,
                                        p_errcode         IN  VARCHAR2,
                                        p_errmesg         IN  VARCHAR2);

END itg_setup;

 

/
