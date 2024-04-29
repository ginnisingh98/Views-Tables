--------------------------------------------------------
--  DDL for Package HR_DM_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DM_INIT" AUTHID CURRENT_USER AS
/* $Header: perdmini.pkh 115.12 2002/03/07 09:31:59 pkm ship     $ */


--
-- Declare records
--

TYPE r_flexfield_rec IS RECORD (
    flexfield_type VARCHAR2(1),
    application_id NUMBER,
    id_flex_code VARCHAR2(4),
    id_flex_structure_code VARCHAR2(30),
    descriptive_flexfield_name VARCHAR2(40),
    descriptive_flex_context_code VARCHAR2(30));


TYPE r_loader_param_rec IS RECORD (
    loader_name             VARCHAR2(30),
    loader_conc_program     VARCHAR2(30),
    loader_config_file      VARCHAR2(30),
    loader_application      VARCHAR2(50),
    loader_params_id        NUMBER,
    application_id          NUMBER,
    parameter1              VARCHAR2(100),
    parameter2              VARCHAR2(100),
    parameter3              VARCHAR2(100),
    parameter4              VARCHAR2(100),
    parameter5              VARCHAR2(100),
    parameter6              VARCHAR2(100),
    parameter7              VARCHAR2(100),
    parameter8              VARCHAR2(100),
    parameter9              VARCHAR2(100),
    parameter10             VARCHAR2(100),
    group_id                NUMBER);


--
PROCEDURE main(r_migration_data IN hr_dm_utility.r_migration_rec);

--


END hr_dm_init;

 

/
