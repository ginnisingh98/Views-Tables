--------------------------------------------------------
--  DDL for Package M4U_SETUP_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_SETUP_PACKAGE" AUTHID CURRENT_USER AS
/* $Header: M4USETPS.pls 120.0 2005/08/01 03:49:46 rkrishan noship $ */

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
                                                x_errbuf                OUT NOCOPY VARCHAR2,
                                                x_retcode               OUT NOCOPY VARCHAR2,
                                                p_txn_subtype           VARCHAR2,
                                                p_map                   VARCHAR2,
                                                p_direction             VARCHAR2,
                                                p_tp_hdr_id             NUMBER
                                         );

        -- Name
        --      SETUP
        -- Purpose
        --      This procedure is called from a concurrent program(can be called from anywhere actually).
        --      This procedure does the setup required for m4u
        --              i)      Setup default TP location in HR_LOCATIONS
        --              ii)     Setup XMLGateway trading partner definition
        -- Arguments
        --      x_err_buf                       => API out result param for concurrent program calls
        --      x_retcode                       => API out result param for concurrent program calls
        --      p_location_code                 => Should have value 'OIPC Default TP'
        --      p_description                   => Some description
        --      p_addr_line_1                   => Some address line 1
        --      p_region_1                      => Some region 1 (province)
        --      p_region_2                      => Some region 2 (State)
        --      p_town_or_city                  => Some city
        --      p_postal_code                   => Some postal code
        -- Notes
        --      All the input arguments are used in the call to setup_hr_locations
        --      The concurrent program will be failed in case of any error
        --      All arguments are moved into the code
        PROCEDURE SETUP(
                           x_errbuf             OUT NOCOPY VARCHAR2,
                           x_retcode            OUT NOCOPY NUMBER

                       );

END M4U_SETUP_PACKAGE;

 

/
