--------------------------------------------------------
--  DDL for Package JTF_TTY_WORKFLOW_POP_BIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_WORKFLOW_POP_BIN_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvpobs.pls 120.0 2005/06/02 18:22:13 appldev ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_WORKFLOW_POP_BIN_PVT
--    PURPOSE
--
--      Procedures:
--         (see below for specification)
--
--
--
--
--    NOTES
--
--
--
--
--    HISTORY
--      09/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--

G_DEBUG BOOLEAN := FALSE;

Procedure populate_bin_startworkflow
( ERRBUF                                OUT NOCOPY  VARCHAR2
, RETCODE                               OUT NOCOPY  VARCHAR2
, p_process_workflow                    IN VARCHAR2
, p_bin_name                            IN VARCHAR2
, p_debug_flag                          IN VARCHAR2
);

procedure print_log(p_string in varchar2);


END  JTF_TTY_WORKFLOW_POP_BIN_PVT;

 

/
