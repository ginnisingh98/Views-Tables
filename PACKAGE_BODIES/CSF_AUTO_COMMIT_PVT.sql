--------------------------------------------------------
--  DDL for Package Body CSF_AUTO_COMMIT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_AUTO_COMMIT_PVT" as
/* $Header: CSFVCMTB.pls 120.0 2005/05/24 17:47:23 appldev noship $ */

  --================================================--
  -- private constants, types, variables and cursors --
  --================================================--

  g_errbuf_success constant varchar2(250) :=
    'Program completed successfully. ';
  g_errbuf_warning constant varchar2(250) :=
    'Program completed with exceptions. ';
  g_errbuf_error   constant varchar2(250) :=
    'Program terminated with exceptions. ';

  g_retcode_success constant number := 0;
  g_retcode_warning constant number := 1;
  g_retcode_error   constant number := 2;

  --=============================================--
  -- private procedure and function declarations --
  --=============================================--

  procedure print ( p_data varchar2 );

  --===========================================--
  -- public procedure and function definitions --
  --===========================================--

  ------------------------------------------
  -- procedure update_planned_task_status --
  ------------------------------------------
  procedure update_planned_task_status
    ( x_errbuf       out nocopy varchar2
    , x_retcode      out nocopy varchar2
    , p_query_id     varchar2 default null
    )
  is

    --
    -- variables for API output parameters
    --
    l_return_status    varchar2(2000);
    l_msg_data         varchar2(2000);
    l_msg_count        number;
    l_task_ovn         number;
    l_task_status_name varchar2(2000);
    l_task_status_id   number;
   l1                  Number;
    --
    --
    l_query_id number;
    --
    --
  begin
    --
    --   initialise
    --
    l_query_id  := fnd_profile.value('CSF_DEFAULT_AUTO_COMMIT_QUERY');
    fnd_message.set_name('CSF', 'CSF_AUTO_COMMIT_STARTED');
    print(fnd_message.get);
    --
    x_errbuf   := g_errbuf_success;
    x_retcode  := g_retcode_success;
    fnd_msg_pub.Initialize;
    --
    If p_query_id is not null then
        l_query_id := p_query_id;
    end if;
    --
    csf_tasks_pub.commit_schedule(
                                 p_api_version     => 1.0
                               , p_init_msg_list   => fnd_api.g_false
                               , p_commit          => fnd_api.g_true
                               , x_return_status   => l_return_status
                               , x_msg_count       => l_msg_count
                               , x_msg_data        => l_msg_data
                               , p_query_id        => l_query_id
                                 );

   if l_return_status <> fnd_api.g_ret_sts_success
   then
     raise fnd_api.g_exc_unexpected_error;
   end if;
        --
        --
           if l_msg_count > 0 then
                 FOR counter IN REVERSE 1..l_msg_count
                  LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     print(l_msg_data);
                  end loop;
           end if;
           fnd_message.set_name('CSF', 'CSF_AUTO_COMMIT_DONE');
           print(fnd_message.get);
    --
exception
    when fnd_api.g_exc_unexpected_error then
          x_errbuf := g_errbuf_warning;
          x_retcode := g_retcode_warning;
           if l_msg_count > 0 then
                  FOR counter IN REVERSE 1..l_msg_count
                  LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     print(l_msg_data);
                  end loop;
           end if;
    when others then
      x_errbuf  := g_errbuf_error;
      x_retcode := g_retcode_error;

           if l_msg_count > 0 then
                 FOR counter IN REVERSE 1..l_msg_count
                  LOOP
                     fnd_msg_pub.get(counter,FND_API.G_FALSE,l_msg_data,l1);
                     print(l_msg_data);
                  end loop;
           end if;
      fnd_message.set_name('CSF', 'CSF_AUTO_COMMIT_EXCEPTION');
      fnd_message.set_token('P_MESSAGE', sqlerrm);
      print(fnd_message.get);
      fnd_message.set_name('CSF', 'CSF_AUTO_COMMIT_ABORT');
      print(fnd_message.get);
  end update_planned_task_status;

  --============================================--
  -- private procedure and function definitions --
  --============================================--

   -----------------------------------------------------
  -- print a message to the output and the log file ---
  -----------------------------------------------------
  procedure print ( p_data varchar2 )
  is
  begin
    fnd_file.put_line(fnd_file.output, p_data);
    fnd_file.put_line(fnd_file.log, p_data);
  end print;

end csf_auto_commit_pvt;

/
