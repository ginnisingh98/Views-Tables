--------------------------------------------------------
--  DDL for Package MSD_TRANSLATE_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_TRANSLATE_TIME_DATA" AUTHID CURRENT_USER AS
/* $Header: msdttims.pls 115.8 2002/12/03 21:14:53 pinamati ship $ */


procedure Explode_Fiscal_Dates(
              errbuf                  OUT nocopy VARCHAR2,
              retcode                 OUT nocopy VARCHAR2,
              p_dest_table            IN  VARCHAR2,
              p_instance_id           IN  NUMBER,
              p_calendar_type_id      IN  NUMBER,
              p_calendar_code         IN  VARCHAR2,
              p_seq_num               IN  NUMBER,
              p_year                  IN  VARCHAR2,
              p_year_description      IN  VARCHAR2,
              p_year_start_date       IN  DATE,
              p_year_end_date         IN  DATE,
              p_quarter               IN  VARCHAR2,
              p_quarter_description   IN  VARCHAR2,
              p_quarter_start_date    IN  DATE,
              p_quarter_end_date      IN  DATE,
              p_month                 IN  VARCHAR2,
              p_month_description     IN  VARCHAR2,
              p_month_start_date      IN  DATE,
              p_month_end_date        IN  DATE,
              p_from_date             IN  DATE,
              p_to_date               IN  DATE) ;


procedure translate_time_data(
                        errbuf                  OUT nocopy VARCHAR2,
                        retcode                 OUT nocopy VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id           IN  NUMBER,
                        p_calendar_type_id      IN  NUMBER,
                        p_calendar_code    	IN  VARCHAR2,
                        p_from_date       	IN  DATE,
                        p_to_date   		IN  DATE) ;

procedure    Generate_Gregorian(
                        errbuf          OUT nocopy VARCHAR2,
                        retcode         OUT nocopy VARCHAR2,
                        p_calendar_code IN  VARCHAR2,
                        p_from_date     IN  DATE,
                        p_to_date       IN  DATE ) ;

procedure fix_manufacturing(errbuf out nocopy varchar2,
                            retcode out nocopy varchar2,
                            p_cal_code in varchar2);

END MSD_TRANSLATE_TIME_DATA ;

 

/
