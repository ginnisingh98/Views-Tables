--------------------------------------------------------
--  DDL for Package FV_GOALS_224
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_GOALS_224" AUTHID CURRENT_USER as
-- $Header: FVTI224S.pls 120.3.12010000.1 2008/07/28 06:32:09 appldev ship $

        PROCEDURE main( errbuf   OUT NOCOPY VARCHAR2,
                        retcode  OUT NOCOPY VARCHAR2,
                        p_ledger_id     IN      NUMBER,
                        p_gl_period     IN      VARCHAR2,
                        p_alc           IN      VARCHAR2,
                        p_partial_or_full IN VARCHAR2,
                        p_business_activity IN VARCHAR2,
                        p_gwa_reporter_category IN VARCHAR2);


	PROCEDURE	process_record_type_01;
	PROCEDURE	process_record_type_02;
	PROCEDURE	process_record_type_03;
	PROCEDURE	process_record_type_04_13;
	PROCEDURE	process_record_type_14;
	PROCEDURE	process_record_type_15;
	PROCEDURE	process_record_type_16_25;
	PROCEDURE	process_record_type_26;
	PROCEDURE	process_record_type_98;
	PROCEDURE	process_record_type_99;


END fv_goals_224;

/
