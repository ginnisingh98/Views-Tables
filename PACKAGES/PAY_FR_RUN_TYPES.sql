--------------------------------------------------------
--  DDL for Package PAY_FR_RUN_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_RUN_TYPES" AUTHID CURRENT_USER As
/* $Header: pyfrrunt.pkh 115.1 2002/12/09 11:05:47 sfmorris noship $ */

Procedure element_run_types(p_element_type_id In Number
                           );
Procedure rebuild_run_types(errbuf out nocopy varchar2 ,
                            retcode out nocopy varchar2
                           );

Procedure rebuild_run_types;

End pay_fr_run_types;

 

/
