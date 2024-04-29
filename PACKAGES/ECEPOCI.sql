--------------------------------------------------------
--  DDL for Package ECEPOCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECEPOCI" AUTHID CURRENT_USER AS
/* $Header: ECPOCIS.pls 120.2.12010000.1 2008/07/25 07:25:38 appldev ship $ */

Procedure Process_POCI_Inbound (
        errbuf                  OUT  NOCOPY   varchar2,
        retcode                 OUT  NOCOPY   varchar2,
        i_file_path             IN      varchar2,
        i_file_name             IN      varchar2,
        i_debug_mode            IN      number,
        i_run_import            IN      varchar2,
        i_num_instances         IN      number default 1,
	i_transaction_type	In      varchar2,
	i_map_id		IN	number,
        i_data_file_characterset  IN    varchar2
--	i_debug_mode		IN	number
--        i_num_instances         IN      number default 1
        );


PROCEDURE def_creation_date(
          p_operation_code     IN VARCHAR2,
          p_creation_date_in   IN  DATE,
          p_creation_date_out  OUT NOCOPY DATE
          );

PROCEDURE def_automatic_flag(
          p_operation_code    IN VARCHAR2,
          p_automatic_flag_in IN VARCHAR2,
          p_automatic_flag_out OUT NOCOPY VARCHAR2
          );

PROCEDURE def_calc_prc_flag(
          p_operation_code    IN VARCHAR2,
          p_calc_prc_flag_in  IN VARCHAR2,
          p_calc_prc_flag_out OUT NOCOPY VARCHAR2
          );

PROCEDURE def_created_by(
          p_operation_code    IN VARCHAR2,
          p_created_by_in     IN NUMBER,
          p_created_by_out    OUT NOCOPY NUMBER
          );

END ECEPOCI;

/
