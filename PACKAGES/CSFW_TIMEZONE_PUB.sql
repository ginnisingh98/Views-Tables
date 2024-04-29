--------------------------------------------------------
--  DDL for Package CSFW_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_TIMEZONE_PUB" AUTHID CURRENT_USER as
/* $Header: csfwtzns.pls 115.4 2003/10/16 07:01:37 srengana ship $ */
-- Start of Comments
-- Package name     : CSFW_TIMEZONE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

    FUNCTION GET_CLIENT_TIME(p_server_time date)
    RETURN date;

    FUNCTION TIME_DIFF_SERVER_TO_CLIENT    RETURN number;

    FUNCTION GET_SERVER_TIME(p_client_time VARCHAR2, p_date_format VARCHAR2)
    RETURN String;



END CSFW_TIMEZONE_PUB;

 

/
