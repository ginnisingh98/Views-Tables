--------------------------------------------------------
--  DDL for Package ZX_SIM_CONDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_SIM_CONDITIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrisimrulespvts.pls 120.3 2004/06/19 01:27:33 ssekuri ship $ */

PROCEDURE create_sim_conditions (p_return_status OUT NOCOPY VARCHAR2,
                                 p_error_buffer  OUT NOCOPY VARCHAR2);

PROCEDURE create_sim_rules (p_trx_id             number,
                            p_trxline_id         number,
                            p_taxline_number     number,
                            p_content_owner_id   number,
                            p_application_id     number,
                            p_tax_regime_code    varchar2,
                            p_tax                varchar2,
                            p_tax_status_code    varchar2,
                            p_rate_code          varchar2,
                            p_return_status  OUT NOCOPY varchar2,
                            p_error_buffer   OUT NOCOPY varchar2);

PROCEDURE create_rules (p_return_status OUT NOCOPY VARCHAR2,
                        p_error_buffer  OUT NOCOPY VARCHAR2);

END zx_sim_conditions_pkg;

 

/
