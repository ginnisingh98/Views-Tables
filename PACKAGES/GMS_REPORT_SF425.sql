--------------------------------------------------------
--  DDL for Package GMS_REPORT_SF425
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_REPORT_SF425" AUTHID CURRENT_USER AS
--$Header: gmsffrcs.pls 120.1.12010000.2 2009/09/10 23:33:52 rmunjulu noship $



   Procedure Populate_425_History(
                               p_award_id          IN NUMBER,
			                   p_report_end_date   IN DATE
                               );

End GMS_REPORT_SF425;


/
