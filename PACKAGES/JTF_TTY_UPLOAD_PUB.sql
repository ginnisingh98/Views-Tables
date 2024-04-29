--------------------------------------------------------
--  DDL for Package JTF_TTY_UPLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_UPLOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptuns.pls 120.0 2005/06/02 18:21:06 appldev noship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_UPLOAD_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This is to store the commonly used (hand-tuned) SQL
--      used by the TAE Generation Program
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is available for PUBLIC use
--
--    HISTORY
--      08/29/03    JDOCHERT  Created
--
--    End of Comments
--

 PROCEDURE create_tg_na ( ERRBUF               OUT NOCOPY  VARCHAR2,
                          RETCODE              OUT NOCOPY  VARCHAR2,
                          p_terr_group_name    IN  VARCHAR2,
                          p_add_salesteam      IN  VARCHAR2 := 'N',
                          p_Debug_Flag         IN  VARCHAR2 := 'N',
                          p_SQL_Trace          IN  VARCHAR2 := 'N'
                         );


END JTF_TTY_UPLOAD_PUB;


 

/
