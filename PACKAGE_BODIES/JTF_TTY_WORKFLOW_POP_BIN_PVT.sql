--------------------------------------------------------
--  DDL for Package Body JTF_TTY_WORKFLOW_POP_BIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TTY_WORKFLOW_POP_BIN_PVT" AS
/* $Header: jtfvpobb.pls 120.0 2005/06/02 18:22:12 appldev ship $ */
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
--      11/15/02    JRADHAKR         CREATED
--
--
--    End of Comments
--

Procedure populate_bin_startworkflow
( ERRBUF                                OUT NOCOPY  VARCHAR2
, RETCODE                               OUT NOCOPY  VARCHAR2
, p_process_workflow                    IN VARCHAR2
, p_bin_name                            IN VARCHAR2
, p_debug_flag                          IN VARCHAR2
)
IS

 l_return_status       VARCHAR2(320) := NULL;
 l_error_message       VARCHAR2(320) := NULL;


BEGIN

  G_DEBUG := TRUE;

  JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Debug flag  ' || p_debug_flag);

  G_DEBUG := FALSE;

  if upper(p_debug_flag) = 'Y' then
    --
    G_DEBUG := TRUE;
    --
  end if;

  if p_process_workflow = 'Y' then
  --
    JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Calling workflow procedure since workflow param is Y ');

    JTF_TTY_CATCHALL_WORKFLOW.Process_catch_all_rec
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );

  end if;


  if p_bin_name <> 'NONE' then

    JTF_TTY_POP_TERR_ADMIN_BIN_PVT.Sync_terr_group
        ( x_return_status             => l_return_status
        , x_error_message             => l_error_message
        );

    IF p_bin_name = 'CATCHALL_BIN' then

      JTF_TTY_POP_TERR_ADMIN_BIN_PVT.populate_catch_all_bin_info
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );

    ELSIF p_bin_name = 'KPI BIN' then

      JTF_TTY_POP_TERR_ADMIN_BIN_PVT.populate_kpi_bin_info
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );

    ELSIF p_bin_name = 'ALL' then

      JTF_TTY_POP_TERR_ADMIN_BIN_PVT.populate_catch_all_bin_info
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );

      JTF_TTY_POP_TERR_ADMIN_BIN_PVT.populate_kpi_bin_info
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );
     JTF_TTY_NA_TERRGP.sum_rm_bin
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );
    ELSIF p_bin_name = 'RM BIN' then

     JTF_TTY_NA_TERRGP.sum_rm_bin
      ( x_return_status             => l_return_status
      , x_error_message             => l_error_message
      );

    END IF;

  end if;
  --
EXCEPTION
   when FND_API.G_EXC_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log('Exception others in populate_bin_startworkflow '||SQLERRM);
      RETURN;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      RETCODE := 1;
      ERRBUF := SQLERRM;
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_bin_startworkflow '||SQLERRM);
      RETURN;
   when others then
      RETCODE := 1;
      JTF_TTY_WORKFLOW_POP_BIN_PVT.print_log ('Exception others in populate_bin_startworkflow '||SQLERRM);

      RETURN;

END populate_bin_startworkflow;


procedure print_log(p_string in varchar2)
is
begin

  if g_debug then
--    dbms_output.put_line(p_string);
    fnd_file.put_line(fnd_file.log,p_string);
  end if;

end print_log;


END  JTF_TTY_WORKFLOW_POP_BIN_PVT;

/
