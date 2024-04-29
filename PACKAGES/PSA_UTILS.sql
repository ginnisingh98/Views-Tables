--------------------------------------------------------
--  DDL for Package PSA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_UTILS" AUTHID CURRENT_USER as
/* $Header: PSAUTILS.pls 115.4 2004/02/16 14:06:43 rgopalan ship $ */

g_session_seq_id    number;
g_msg_num           number;

-- ==============================FND_LOG===================================--
/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_unexpected_msg                                                 |
 |                                                                         |
 | Description:                                                            |
 |    This procedure is for fnd logging and call this to log the seeded    |
 |       message IGI_LOGGING_UNEXP_ERROR when no message is there in the   |
 |        Unexpected(WHEN OTHERS THEN) Exception section                   |
 |                                                                         |
 | History                                                                 |
 |  16-JAN-04  Harikiran       Created                                     |
 +=========================================================================*/

PROCEDURE debug_unexpected_msg(p_full_path IN VARCHAR2);

/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_other_msg                                                      |
 |                                                                         |
 | Description:                                                            |
 |    This procedure is for fnd logging and call this to log messages      |
 |         in all the other cases                                          |
 |                                                                         |
 | History                                                                 |
 |  16-JAN-04  Harikiran       Created                                     |
 +=========================================================================*/

PROCEDURE debug_other_msg(p_level IN NUMBER,
			      p_full_path IN VARCHAR2,
			      p_remove_from_stack IN BOOLEAN);

/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_other_string                                                   |
 |                                                                         |
 | Description:                                                            |
 |    This procedure is for fnd logging and call this to log               |
 |           Hard Coded String messages                                    |
 |                                                                         |
 | History                                                                 |
 |  16-JAN-04  Harikiran       Created                                     |
 +=========================================================================*/

PROCEDURE debug_other_string(p_level IN NUMBER,
          			     p_full_path IN VARCHAR2,
                                     p_string IN VARCHAR2);

-- ==============================END==============================--
PROCEDURE debug_mesg (p_msg IN   VARCHAR2  );
END ;

 

/
