--------------------------------------------------------
--  DDL for Package ECX_OBFUSCATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_OBFUSCATE" AUTHID CURRENT_USER AS
-- $Header: ECXENCRS.pls 120.2 2005/06/30 11:15:27 appldev ship $

PROCEDURE ecx_data_encrypt(l_input_string      IN  varchar2,
                           l_output_string  OUT NOCOPY varchar2,
                           errmsg              OUT NOCOPY varchar2,
                           retcode             OUT NOCOPY pls_integer);

PROCEDURE ecx_data_encrypt(l_input_string IN  varchar2,
			   l_qual_code    IN  varchar2,
                           l_output_string   OUT NOCOPY varchar2,
                           errmsg               OUT NOCOPY varchar2,
                           retcode              OUT NOCOPY pls_integer);
END;

 

/
