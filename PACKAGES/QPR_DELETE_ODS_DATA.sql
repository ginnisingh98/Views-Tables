--------------------------------------------------------
--  DDL for Package QPR_DELETE_ODS_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DELETE_ODS_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRUDODS.pls 120.0 2007/10/11 13:12:27 agbennet noship $ */
procedure delete_measure_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_measure_code in varchar2,
                              p_from_date in varchar2,
                              p_to_date in varchar2,
                              p_dim_code in varchar2 default 'ALL',
                              p_dummy_dim_code in varchar2 default null,
                              p_dim_value_from in varchar2,
                              p_dim_value_to in varchar2);

procedure delete_dimension_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_dim_code in varchar2,
                              p_dummy_dim_code in varchar2 default null,
                              p_dim_value_from in varchar2,
                              p_dim_value_to in varchar2);
END;


/
