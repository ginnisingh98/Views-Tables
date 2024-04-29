--------------------------------------------------------
--  DDL for Package Body CAC_TASK_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_TASK_PURGE_PUB" AS
/* $Header: cactkprb.pls 120.17 2006/02/03 03:47:40 sbarat noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cactkprb.pls                                                         |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |        function.                                                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date         Developer             Change                             |
 | ------       ---------------       -----------------------------------|
 | 07--2005     Rahul Shrivastava     Created                            |
 | 03-Feb-2006  Swapan Barat          Added calls to UWQ and IH's purge  |
 |                                    APIs for bug# 4997851              |
 +======================================================================*/


   procedure delete_atth_to_tasks(
         x_return_status           OUT  NOCOPY VARCHAR2,
         x_msg_data                OUT  NOCOPY VARCHAR2,
         x_msg_count               OUT  NOCOPY NUMBER,
         p_object_type             IN          VARCHAR2,
         p_processing_set_id       IN          NUMBER)

       is



         cursor c_fetch_task_ids is
	   select b.task_id
	     from jtf_tasks_b b, fnd_attached_documents fad
	     where b.source_object_type_code = p_object_type
	       and b.source_object_id in ( select object_id
	                                  from jtf_object_purge_param_tmp
	 				    where processing_set_id = p_processing_set_id
				      and ( purge_status is null or purge_status <> 'E'))
          and fad.entity_name='JTF_TASKS_B'
          and fad.pk1_value=to_char(b.task_id);


         TYPE t_tab_num       Is Table Of NUMBER;
	      l_tab_task_ids        t_tab_num:=t_tab_num();
              l_entity_name        VARCHAR2(30) := 'JTF_TASKS_B';
              l_api_version	 CONSTANT NUMBER := 1.0;
              l_api_name	 CONSTANT VARCHAR2(30) := 'delete_atth_to_tasks';
         Begin


      SAVEPOINT purge_task_attach;
      x_return_status := fnd_api.g_ret_sts_success;



      Open c_fetch_task_ids;
      Fetch c_fetch_task_ids Bulk Collect Into l_tab_task_ids;
      Close c_fetch_task_ids;


      IF l_tab_task_ids.COUNT > 0
      THEN

          -- Calling delete attachment API
	    For j In 1.. l_tab_task_ids.LAST loop

             fnd_attached_documents2_pkg.delete_attachments(X_entity_name=>l_entity_name,
	     	X_pk1_value =>to_char(l_tab_task_ids(j)),
	       	X_pk2_value => NULL,
	     	X_pk3_value => NULL,
	    	X_pk4_value => NULL,
	    	X_pk5_value => NULL,
	    	X_delete_document_flag =>'Y',
	    	X_automatically_added_flag => NULL) ;

            end loop;


     END IF;--for    IF l_tab_task_ids.COUNT > 0

        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

   EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
  	   ROLLBACK TO purge_task_attach;
  	   x_return_status := fnd_api.g_ret_sts_unexp_error;
           fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
       if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_return_status= '||x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_msg_data= '||x_msg_data);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_msg_count= '||x_msg_count);
       end if;

        WHEN OTHERS
        THEN
  	   ROLLBACK TO purge_task_attach;
  	   fnd_message.set_name ('JTF', 'JTF_ATTACHMENT_PURGE_EXCEP');
  	   fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
  	   fnd_msg_pub.add;
       if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_return_status= '||x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_msg_data= '||x_msg_data);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.delete_atth_to_tasks', ' x_msg_count= '||x_msg_count);
       end if;

  	   x_return_status := fnd_api.g_ret_sts_unexp_error;
  	   fnd_msg_pub.count_and_get (
  	                            p_count => x_msg_count,
  	                            p_data => x_msg_data
	                             );

 end delete_atth_to_tasks;

  Procedure purge_tasks(
      p_api_version           IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN          VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status         OUT  NOCOPY VARCHAR2,
      x_msg_data              OUT  NOCOPY VARCHAR2,
      x_msg_count             OUT  NOCOPY NUMBER,
      p_object_type           IN          VARCHAR2,
      p_processing_set_id     IN          NUMBER)

      IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	 CONSTANT VARCHAR2(30) := 'PURGE_TASKS';

      Cursor get_tasks_ids(b_processing_set_id NUMBER,b_object_type VARCHAR2)
           is

            Select task_id
             from jtf_tasks_b
              Where source_object_type_code=b_object_type
               And source_object_id in
               (select distinct object_id from jtf_object_purge_param_tmp
                 where processing_set_id=b_processing_set_id and
                  purge_status is null and object_type=b_object_type)
            and entity='TASK';

      TYPE tab_task_ids is table of NUMBER;
      l_tab_tasks_id                  tab_task_ids:=tab_task_ids();
      proc_seq_num                  NUMBER;
      l_msg_index_out             VARCHAR2(100);
      BEGIN

     SAVEPOINT purge_tasks;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	  RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	  fnd_msg_pub.initialize;
      END IF;
  --Logging input parameters

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_task_purge_pub.purge_tasks', ' p_object_type= '||p_object_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_task_purge_pub.purge_tasks', ' p_processing_set_id= '||p_processing_set_id);
    end if;


      Open get_tasks_ids(p_processing_set_id ,p_object_type );
         Fetch get_tasks_ids Bulk Collect Into l_tab_tasks_id;

       if    (get_tasks_ids%ISOPEN)  then
      Close get_tasks_ids;
      END IF;

      If ( l_tab_tasks_id.COUNT > 0)  then

--inserting data into the global temp table
      select jtf_object_purge_proc_set_s.nextval into proc_seq_num from dual;



 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Inserting task data into global tem table');
  end if;

         FORALL i in l_tab_tasks_id.first..l_tab_tasks_id.last

          Insert into jtf_object_purge_param_tmp  p
            ( processing_set_id,object_id,object_type,purge_status,purge_error_message)
          values
          (proc_seq_num, l_tab_tasks_id(i),'TASK', null,null);



  --Calling the purge APIs for notes , UWQ, Mobile Field Service, Attachments
  -- and interaction center to purge any references

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling  CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS');
  end if;

    CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS(
      P_API_VERSION                => 1.0,
      P_INIT_MSG_LIST              => FND_API.G_FALSE,
      P_COMMIT                     => FND_API.G_FALSE,
      P_PROCESSING_SET_ID          => proc_seq_num ,
      P_OBJECT_TYPE                => 'TASK' ,
      X_RETURN_STATUS              => x_return_status,
      X_MSG_COUNT                  => x_msg_count,
      X_MSG_DATA                   => x_msg_data);

       IF NOT (x_return_status = fnd_api.g_ret_sts_success)
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

       if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling  CSM_TASK_PURGE_PKG.DELETE_MFS_TASKS');
       end if;
         RAISE fnd_api.g_exc_unexpected_error;
       end if;

    /************* Start of addition by SBARAT on 03/02/2006 for bug# 4997851 *************/

    -- Calling UWQ's purge API

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling IEU_WR_PUB.PURGE_WR_ITEM');
    END IF;

    IEU_WR_PUB.Purge_Wr_Item(
      p_api_version_number => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_commit             => FND_API.G_FALSE,
      p_processing_set_id  => proc_seq_num,
      p_object_type        => 'TASK',
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data);

    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
    THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;

        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling IEU_WR_PUB.PURGE_WR_ITEM');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    -- Calling Interaction History's purge API

    IF( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
    THEN
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling JTF_IH_PURGE.P_DELETE_INTERACTIONS');
    END IF;

    JTF_IH_PURGE.P_Delete_Interactions(
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_commit             => FND_API.G_FALSE,
      p_processing_set_id  => proc_seq_num,
      p_object_type        => 'TASK',
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data);

    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
    THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;

        IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL)
        THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling JTF_IH_PURGE.P_DELETE_INTERACTIONS');
        END IF;

        RAISE fnd_api.g_exc_unexpected_error;

    END IF;

    /************* End of addition by SBARAT on 03/02/2006 for bug# 4997851 *************/

  --calling attachment deletion wrapper api.
    if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling  cac_task_purge_pub.delete_atth_to_tasks');
   end if;


    delete_atth_to_tasks(
    p_processing_set_id=>proc_seq_num,
    p_object_type      =>'TASK',
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data);

   IF NOT (x_return_status = fnd_api.g_ret_sts_success)

     THEN

     x_return_status := fnd_api.g_ret_sts_unexp_error;


     if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then

      FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling  cac_task_purge_pub.delete_atth_to_tasks');
     end if;
            RAISE fnd_api.g_exc_unexpected_error;
    end if;


 --Calling notes api
   if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling  cac_note_purge_pub.purge_notes');
   end if;



        cac_note_purge_pub.purge_notes(
              p_api_version       => 1.0,
              x_return_status     => x_return_status,
              x_msg_count         => x_msg_count,
              x_msg_data          => x_msg_data,
              p_processing_set_id => proc_seq_num,
              p_object_type       => 'TASK' );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
          x_return_status := fnd_api.g_ret_sts_unexp_error;

        if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling  cac_note_purge_pub.purge_notes');
        end if;
          RAISE fnd_api.g_exc_unexpected_error;
       end if;


  --calling the cac_task_purge_pvt.purge_task_entities API

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'Before calling  cac_task_purge_pvt.purge_task_entities');
  end if;

    cac_task_purge_pvt.purge_task_entities(
          p_api_version       => 1.0,
      	  p_init_msg_list     => fnd_api.g_false,
      	  p_commit            => fnd_api.g_false,
     	  x_return_status     => x_return_status,
          x_msg_data          => x_msg_data,
          x_msg_count         => x_msg_count,
    	  p_processing_set_id => proc_seq_num,
    	  p_object_type       => 'TASK'
    	  );



     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;

     if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', ' return status error after calling  cac_task_purge_pvt.purge_task_entities');
     end if;

     RAISE fnd_api.g_exc_unexpected_error;
     END IF;


  else --no task data exists for the selected service requests
        --else for   If ( get_task_processing_set_id.COUNT > 0)  then

 -- dbms_output.put_line(' point 5');

        if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.purge_tasks', 'no task data exists for the given processing set id ');
        end if;

end if;-- for    If ( l_tab_tasks_id.COUNT > 0)


      IF fnd_api.to_boolean (p_commit)
      THEN
      COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
	ROLLBACK TO purge_tasks;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
       if    (get_tasks_ids%ISOPEN)  then
      Close get_tasks_ids;
      END IF;
    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        IF
            FND_MSG_PUB.Count_Msg > 0
        THEN
            FOR
                i IN 1..FND_MSG_PUB.Count_Msg
            LOOP
                FND_MSG_PUB.Get
                    (
                        p_msg_index     => i
                    ,   p_encoded       => 'F'
                    ,   p_data          => x_msg_data
                    ,   p_msg_index_out => l_msg_index_out
                    );
                fnd_log.string
                    (
                        fnd_log.level_exception
                    ,   'Purge Test'
                    ,   'Error is ' || x_msg_data || ' [Index:' || l_msg_index_out || ']'
                    );
            END LOOP;
        END IF ;
     END IF;

    WHEN OTHERS
    THEN
	ROLLBACK TO purge_tasks;
	fnd_message.set_name ('JTF', 'CAC_TASK_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
       if    (get_tasks_ids%ISOPEN)  then
      Close get_tasks_ids;
      END IF;
	fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        IF
            FND_MSG_PUB.Count_Msg > 0
        THEN
            FOR
                i IN 1..FND_MSG_PUB.Count_Msg
            LOOP
                FND_MSG_PUB.Get
                    (
                        p_msg_index     => i
                    ,   p_encoded       => 'F'
                    ,   p_data          => x_msg_data
                    ,   p_msg_index_out => l_msg_index_out
                    );
                fnd_log.string
                    (
                        fnd_log.level_exception
                    ,   'Purge Test'
                    ,   'Error is ' || x_msg_data || ' [Index:' || l_msg_index_out || ']'
                    );
            END LOOP;
        END IF ;
     END IF;

 END purge_tasks;



     Procedure validate_tasks(
      p_api_version             IN          NUMBER,
      p_init_msg_list           IN          VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN          VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status           OUT  NOCOPY VARCHAR2,
      x_msg_data                OUT  NOCOPY VARCHAR2,
      x_msg_count               OUT  NOCOPY NUMBER,
      p_object_type             IN          VARCHAR2,
      p_processing_set_id       IN          NUMBER,
      p_purge_source_with_open_task IN          VARCHAR2 DEFAULT 'N')
      IS
      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	 CONSTANT VARCHAR2(30) := 'VALIDATE_TASKS';

     Cursor tasks_ids(b_processing_set_id NUMBER,b_object_type VARCHAR2)
     is

      Select task_id
       from jtf_tasks_b
        Where source_object_type_code=b_object_type
         And source_object_id in
         (select distinct object_id from jtf_object_purge_param_tmp
           where processing_set_id=b_processing_set_id and
            purge_status is null and object_type=b_object_type)
            and entity='TASK';


      TYPE tab_task_ids is table of NUMBER;
      l_tab_tasks_id                  tab_task_ids:=tab_task_ids();
      proc_seq_num                  NUMBER;
 l_msg_index_out             VARCHAR2(100);
      BEGIN
     SAVEPOINT validate_tasks;
      x_return_status := fnd_api.g_ret_sts_success;

      IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
      THEN
	  RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
	  fnd_msg_pub.initialize;
      END IF;
  --Logging input parameters

    if( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	 FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_task_purge_pub.validate_tasks', ' p_object_type= '||p_object_type);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_task_purge_pub.validate_tasks', ' p_processing_set_id= '||p_processing_set_id);
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'cac_task_purge_pub.validate_tasks', ' p_purge_source_with_open_task= '||p_purge_source_with_open_task);
    end if;


--calling validations for tasks

   if (p_purge_source_with_open_task='N') then

    Update jtf_object_purge_param_tmp joppt
     Set joppt.PURGE_STATUS='E', joppt.PURGE_ERROR_MESSAGE='JTF:JTF_TASK_PURGE_VALID_FAIL'
      where joppt.processing_set_id=p_processing_set_id
       and  joppt.object_type=p_object_type
        and exists ( select 1 from jtf_tasks_b where
                     source_object_type_code=joppt.object_type
                     and nvl(open_flag,'Y')='Y'
                     and source_object_id=joppt.object_id
                     and entity='TASK');


    end if;


     Open tasks_ids(p_processing_set_id ,p_object_type );
        Fetch tasks_ids Bulk Collect Into l_tab_tasks_id;

      if    (tasks_ids%ISOPEN)  then
     Close tasks_ids;
     END IF;

      If ( l_tab_tasks_id.COUNT > 0)  then

      select jtf_object_purge_proc_set_s.nextval into proc_seq_num from dual;

         FORALL i in l_tab_tasks_id.first..l_tab_tasks_id.last

          Insert into jtf_object_purge_param_tmp  p
            ( processing_set_id,object_id,object_type,purge_status,purge_error_message)
          values
          (proc_seq_num, l_tab_tasks_id(i),'TASK', null,null);

 --call MFS validation API

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.validate_tasks', 'Before calling  CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS');
  end if;

    CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS(
      P_API_VERSION                => 1.0,
      P_INIT_MSG_LIST              => FND_API.G_FALSE,
      P_COMMIT                     => FND_API.G_FALSE,
      P_PROCESSING_SET_ID          => proc_seq_num ,
      P_OBJECT_TYPE                => 'TASK' ,
      X_RETURN_STATUS              => x_return_status,
      X_MSG_COUNT                  => x_msg_count,
      X_MSG_DATA                   => x_msg_data);

       IF NOT (x_return_status = fnd_api.g_ret_sts_success)
       THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

       if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_task_purge_pub.purge_tasks', 'return status error after calling  CSM_TASK_PURGE_PKG.VALIDATE_MFS_TASKS');
       end if;
         RAISE fnd_api.g_exc_unexpected_error;
       end if;


--bulk update the rows with error status E for which tasks validations have failed.

  if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'cac_task_purge_pub.validate_tasks', ' before updating jtf_object_purge_param_tmp');
  end if;

             Update jtf_object_purge_param_tmp  temp
               Set temp.purge_status='E',
                   temp.purge_error_message=(select  purge_error_message from jtf_object_purge_param_tmp
                     where processing_set_id=proc_seq_num
                      and object_type='TASK'
                      and object_id in (select task_id from jtf_tasks_b
                          where source_object_id=temp.object_id
                          and   source_object_type_code=temp.object_type and
                            entity='TASK') and
                          purge_status is not null and rownum =1)
               Where temp.processing_set_id=p_processing_set_id
               and  temp.object_type=p_object_type
               and temp.object_id in

               ( select distinct b.source_object_id from jtf_tasks_b b,
               jtf_object_purge_param_tmp temp where temp.object_id=b.task_id and
               temp.processing_set_id=proc_seq_num and  temp.object_type='TASK' and temp.purge_status is not null
               and b.entity='TASK');


          END IF;-- for   If ( l_tab_tasks_id.COUNT > 0)  then

	 IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
       x_return_status := fnd_api.g_ret_sts_unexp_error;
     RAISE fnd_api.g_exc_unexpected_error;
     END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
      COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
	ROLLBACK TO validate_tasks;
          if    (tasks_ids%ISOPEN)  then
           CLOSE tasks_ids;
          end if;
	x_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);


    if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        IF
            FND_MSG_PUB.Count_Msg > 0
        THEN
            FOR
                i IN 1..FND_MSG_PUB.Count_Msg
            LOOP
                FND_MSG_PUB.Get
                    (
                        p_msg_index     => i
                    ,   p_encoded       => 'F'
                    ,   p_data          => x_msg_data
                    ,   p_msg_index_out => l_msg_index_out
                    );
                fnd_log.string
                    (
                        fnd_log.level_exception
                    ,   'Purge Test'
                    ,   'Error is ' || x_msg_data || ' [Index:' || l_msg_index_out || ']'
                    );
            END LOOP;
        END IF ;
     END IF;

WHEN OTHERS
    THEN
	ROLLBACK TO validate_tasks;
	 if    (tasks_ids%ISOPEN)  then
	     CLOSE tasks_ids;
         end if;
	fnd_message.set_name ('JTF', 'JTF_TASK_VALID_UNKNOWN_ERR');
	fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
	fnd_msg_pub.add;
	x_return_status := fnd_api.g_ret_sts_unexp_error;

 if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             IF FND_MSG_PUB.Count_Msg > 0
        THEN
            FOR
                i IN 1..FND_MSG_PUB.Count_Msg
            LOOP
                FND_MSG_PUB.Get
                    (
                        p_msg_index     => i
                    ,   p_encoded       => 'F'
                    ,   p_data          => x_msg_data
                    ,   p_msg_index_out => l_msg_index_out
                    );


             fnd_log.string
                    (
                        fnd_log.level_exception
                    ,   'Purge Test'
                    ,   'Error is ' || x_msg_data || ' [Index:' || l_msg_index_out || ']'
                    );
            END LOOP;
        END IF ;

  END IF;

END validate_tasks;

END CAC_TASK_PURGE_PUB;

/
