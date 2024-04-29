--------------------------------------------------------
--  DDL for Package FUN_NET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_UTIL" AUTHID CURRENT_USER AS
/* $Header: funntuts.pls 120.1 2005/12/23 14:09:56 asrivats noship $ */

    -- ============================ FND_LOG Start ===========================--
    /*=========================================================================+
     | Procedure Name:                                                         |
     |    Log_Unexpected_Msg                                                 |
     |                                                                         |
     | Description:                                                            |
     |    This procedure is for fnd logging and call this to log the seeded    |
     |       message FUN_LOGGING_UNEXP_ERROR when no message is there in the   |
     |        Unexpected(WHEN OTHERS THEN) Exception section                   |
     |                                                                         |
     | History                                                                 |
     |
     +=========================================================================*/

    PROCEDURE Log_Unexpected_Msg(p_full_path IN VARCHAR2);

    /*=========================================================================+
     | Procedure Name:                                                         |
     |    Log_Msg                                                      |
     |                                                                         |
     | Description:                                                            |
     |    This procedure is for fnd logging and call this to log messages      |
     |         in all the other cases                                          |
     |                                                                         |
     | History                                                                 |
     |
     +=========================================================================*/

    PROCEDURE Log_Msg(p_level               IN NUMBER,
			             p_full_path            IN VARCHAR2,
			             p_remove_from_stack    IN BOOLEAN);

    /*=========================================================================+
     | Procedure Name:                                                         |
     |    Log_String                                                   |
     |                                                                         |
     | Description:                                                            |
     |    This procedure is for fnd logging and call this to log               |
     |           Hard Coded String messages                                    |
     |                                                                         |
     | History                                                                 |
     |
     +=========================================================================*/

    PROCEDURE Log_String(p_level      IN NUMBER,
                             p_full_path  IN VARCHAR2,
                             p_string     IN VARCHAR2);

    -- ========================= FND_LOG End ==============================--

    FUNCTION Round_Currency(
			P_Amount         IN number
                       ,P_Currency_Code  IN varchar2)
    RETURN NUMBER;
END FUN_NET_UTIL; -- Package spec

 

/
