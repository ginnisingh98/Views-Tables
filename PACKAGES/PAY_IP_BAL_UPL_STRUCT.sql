--------------------------------------------------------
--  DDL for Package PAY_IP_BAL_UPL_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IP_BAL_UPL_STRUCT" AUTHID CURRENT_USER AS
/* $Header: pyipbups.pkh 115.1 2002/12/04 12:14:04 atrivedi noship $ */


   PROCEDURE create_bal_upl_struct (errbuf			OUT NOCOPY varchar2,
				    retcode			OUT NOCOPY number,
				    p_input_value_limit		number,
				    p_batch_id			number);

END pay_ip_bal_upl_struct;

 

/
