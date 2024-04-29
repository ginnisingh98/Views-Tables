--------------------------------------------------------
--  DDL for Package PA_FCK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FCK_UTIL" AUTHID CURRENT_USER as
/* $Header: PABFUTLS.pls 120.0 2005/05/29 19:38:38 appldev noship $ */

g_session_seq_id    number;
g_msg_num           number;
PROCEDURE debug_msg ( p_msg             IN   VARCHAR2  );
END PA_FCK_UTIL;

 

/
