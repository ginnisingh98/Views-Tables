--------------------------------------------------------
--  DDL for Package MSD_SOP_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_SOP_FACT_DATA" AUTHID CURRENT_USER AS
/* $Header: msdsfdcs.pls 120.1 2005/12/08 22:22:55 sjagathe noship $ */


    Type cs_name_rec is RECORD (
        cs_name            varchar2(30)
        );
    Type cs_name_list is TABLE of cs_name_rec index by binary_integer;


    Type cs_id_rec is RECORD (
        cs_definition_id       number
        );
    Type cs_id_list is TABLE of cs_id_rec index by binary_integer;


    PROCEDURE sop_fact_data_collect(errbuf             OUT NOCOPY VARCHAR2,
                                   retcode             OUT NOCOPY VARCHAR2,
                                   p_instance_id       IN NUMBER,
                                   p_date_from	       IN VARCHAR2,
                                   p_date_to           IN VARCHAR2,
                                /* p_booking_data      IN NUMBER,
                                   p_shipment_data     IN NUMBER,             Bug# 4867205*/
                                   p_total_backlog     IN NUMBER,
                                   p_pastdue_backlog   IN NUMBER,
                                   p_onhand_inventory  IN NUMBER,
                                   p_production_plan   IN NUMBER,
                                   p_actual_production IN NUMBER
                                       );


    PROCEDURE sop_fact_data_pull(errbuf      OUT NOCOPY VARCHAR2,
                                 retcode     OUT NOCOPY VARCHAR2
                                );

END MSD_SOP_FACT_DATA;

 

/
