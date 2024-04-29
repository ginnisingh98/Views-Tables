--------------------------------------------------------
--  DDL for Package PAY_IN_BAL_UPL_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_BAL_UPL_STRUCT" AUTHID CURRENT_USER AS
/* $Header: pyinbups.pkh 120.0 2005/05/29 05:49 appldev noship $ */


   PROCEDURE create_bal_upl_struct (errbuf			OUT NOCOPY VARCHAR2,
				    retcode			OUT NOCOPY NUMBER,
				    p_input_value_limit		NUMBER,
				    p_batch_id			NUMBER);

END pay_in_bal_upl_struct;

 

/
