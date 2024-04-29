--------------------------------------------------------
--  DDL for Package EAM_METR_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_METR_VALIDATOR" AUTHID CURRENT_USER AS
/* $Header: EAMETRVS.pls 115.4 2003/11/19 03:04:56 lllin ship $ */

  procedure validate(p_current_rowid in rowid,
                     p_interface_id in number);

  procedure populate_reading(p_current_rowid in rowid,
                     p_interface_id in number);

  procedure populate_who(p_current_rowid in rowid,
                         p_interface_id in number);


  procedure last_updated_by_name(p_current_rowid in rowid,
                                 p_interface_id in number);

  procedure last_updated_by(p_current_rowid in rowid,
                            p_interface_id in number);


  procedure created_by_name(p_current_rowid in rowid,
                            p_interface_id in number);

  procedure created_by(p_current_rowid in rowid,
                       p_interface_id in number);

  procedure organization_code(p_current_rowid in rowid,
                              p_interface_id in number);

  procedure organization_id(p_current_rowid in rowid,
                            p_interface_id in number);

  procedure work_order_name_id(p_current_rowid in rowid,
                               p_interface_id in number);

  procedure meter_name(p_current_rowid in rowid,
                       p_interface_id in number,
                       p_retcode out NOCOPY varchar2);

  procedure meter_id(p_current_rowid in rowid,
                     p_interface_id in number,
                     p_retcode out NOCOPY varchar2);

  procedure reading_date(p_current_rowid in rowid,
                         p_interface_id in number);

  procedure reset_flag(p_current_rowid in rowid,
                       p_interface_id in number);

  procedure reading_values(p_current_rowid in rowid,
                           p_interface_id in number);

END eam_metr_validator;

 

/
