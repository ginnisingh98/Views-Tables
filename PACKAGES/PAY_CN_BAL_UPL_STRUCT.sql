--------------------------------------------------------
--  DDL for Package PAY_CN_BAL_UPL_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_BAL_UPL_STRUCT" AUTHID CURRENT_USER AS
/* $Header: pycnbups.pkh 115.0 2003/05/15 15:08:27 statkar noship $ */

   PROCEDURE create_bal_upl_struct (errbuf		OUT NOCOPY VARCHAR2
				   ,retcode		OUT NOCOPY NUMBER
				   ,p_input_value_limit	NUMBER
				   ,p_batch_id		NUMBER);

END pay_cn_bal_upl_struct;

 

/
