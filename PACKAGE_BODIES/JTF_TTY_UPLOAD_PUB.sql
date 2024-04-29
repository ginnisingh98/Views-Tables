--------------------------------------------------------
--  DDL for Package Body JTF_TTY_UPLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_UPLOAD_PUB" AS
/* $Header: jtfptunb.pls 120.0 2005/06/02 18:21:05 appldev noship $ */
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

 /* Add Organizations to a TG, i.e., transformation of
 ** Organization to a Named Account
 */
 PROCEDURE create_tg_na ( ERRBUF               OUT NOCOPY  VARCHAR2,
                          RETCODE              OUT NOCOPY  VARCHAR2,
                          p_terr_group_name    IN  VARCHAR2,
                          p_add_salesteam      IN  VARCHAR2 := 'N',
                          p_Debug_Flag         IN  VARCHAR2 := 'N',
                          p_SQL_Trace          IN  VARCHAR2 := 'N'
                         )
 AS

    G_Debug                       BOOLEAN  := FALSE;
    g_ProgramStatus               NUMBER   := 0;

    l_counter           number := 0;
    startime            date;
    l_return_status     VARCHAR2(30);
    lX_Msg_Count        NUMBER;
    lX_Msg_Data         VARCHAR2(2000);
    lx_runtime          VARCHAR2(300);
    lx_retcode          VARCHAR2(100);
    lx_errbuf           varchar2(3000);

 			l_message           VARCHAR2(2000);
    l_count				         number := 0;

				l_t1                VARCHAR2(30);
    l_t2                VARCHAR2(30);

				l_source_id             NUMBER := -1001;
				l_trans_object_type_id  NUMBER := -1002;

    i                   NUMBER := 1;
    lp_sysdate          DATE := SYSDATE;
    v_statement         VARCHAR2(2000);

    l_terr_group_id     NUMBER;

 BEGIN

    -- If the SQL trace flag is turned on, then turm on the trace
    If upper(p_SQL_Trace) = 'Y' Then
       dbms_session.set_sql_trace(TRUE);
    --Else
    --   dbms_session.set_sql_trace(FALSE);
    End If;

END create_tg_na;


END JTF_TTY_UPLOAD_PUB;


/
