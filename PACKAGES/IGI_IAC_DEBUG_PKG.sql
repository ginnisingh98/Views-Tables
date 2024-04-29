--------------------------------------------------------
--  DDL for Package IGI_IAC_DEBUG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IAC_DEBUG_PKG" AUTHID CURRENT_USER AS
/* $Header: igiiades.pls 120.3.12000000.1 2007/08/01 16:14:43 npandya ship $ */

/*=========================================================================+
 | Function Name:                                                          |
 |    debug                                                                |
 |                                                                         |
 | Description:                                                            |
 |    This function is for debug purpose  writes inmto temperaory file     |
 |    or writes to log or output file                                      |
 |                                                                         |
 +=========================================================================*/
PROCEDURE debug_on(p_calling_function varchar2);

PROCEDURE debug_off;

PROCEDURE debug(p_debug_type Number,p_debug IN VARCHAR2);

-- ==============================FND_LOG===================================--
/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_unexpected_msg                                               |
 |                                                                         |
 | Description:                                                            |
 |    This procedure is for fnd logging and call this to log the seeded    |

 |       message IGI_LOGGING_UNEXP_ERROR when no message is there in the   |
 |        Unexpected(WHEN OTHERS THEN) Exception section                   |
 |                                                                         |
 |   Created By: Harikiran                                                 |
 +=========================================================================*/

PROCEDURE debug_unexpected_msg(p_full_path IN VARCHAR2);

/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_other_msg                                               |
 |                                                                         |
 | Description:                                                            |

 |    This procedure is for fnd logging and call this to log messages      |
 |         in all the other cases                                          |
 |                                                                         |
 |   Created By: Harikiran                                                 |
 +=========================================================================*/

PROCEDURE debug_other_msg(p_level IN NUMBER,
			  p_full_path IN VARCHAR2,
			  p_remove_from_stack IN BOOLEAN);

/*=========================================================================+
 | Procedure Name:                                                         |
 |    debug_other_string                                            |

 |                                                                         |
 | Description:                                                            |
 |    This procedure is for fnd logging and call this to log               |
 |           Hard Coded String messages                                    |
 |                                                                         |
 | Created By: Harikiran                                                   |
 |                                                                         |
 +=========================================================================*/

PROCEDURE debug_other_string(p_level IN NUMBER,
			     p_full_path IN VARCHAR2,
			     p_string IN VARCHAR2);
-- ==============================END==============================

END;


 

/
