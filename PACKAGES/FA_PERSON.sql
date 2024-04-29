--------------------------------------------------------
--  DDL for Package FA_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_PERSON" AUTHID CURRENT_USER as
/* $Header: fapkpers.pls 120.1.12010000.3 2009/08/05 14:38:31 bridgway ship $ */


  PROCEDURE fa_predel_validation (p_person_id	IN number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);


END FA_PERSON;

/
